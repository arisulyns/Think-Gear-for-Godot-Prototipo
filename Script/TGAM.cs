using Godot;
using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;

#if GODOT_WINDOWS || GODOT_LINUX
using System.IO.Ports;
#endif

public partial class TGAM : Node
{
	// Configurações da porta serial
	[Export] public string PortName = "COM4";
	[Export] public int BaudRate = 57600;

#if GODOT_WINDOWS || GODOT_LINUX
	private SerialPort _serialPort;
#else
	private class DummySerialPort
	{
		public bool IsOpen { get; set; }
		public int BytesToRead => 0;
		public void Open() {}
		public void Close() {}
		public int Read(byte[] buffer, int offset, int count) => 0;
	}
	private DummySerialPort _serialPort = new DummySerialPort();
#endif

	// Dados do EEG
	private int _rawWave;
	private readonly float[] _eegPower = new float[8];
	private int _noise;
	private int _attention;
	private int _meditation;
	
	// Nomes das bandas de EEG
	private readonly string[] _eegBandNames = {
		"Delta", "Theta", "Low Alpha", "High Alpha",
		"Low Beta", "High Beta", "Low Gamma", "Mid Gamma"
	};

	// Máquina de estados para parsing
	private enum ParserState
	{
		Sync1,
		Sync2,
		PayloadLength,
		Payload,
		Checksum
	}
	
	private ParserState _parserState = ParserState.Sync1;
	private int _payloadLength;
	private List<byte> _payloadBytes = new List<byte>();

	// Public properties for GDScript access
	public int RawWave => _rawWave;
	public float[] EEGPower => _eegPower;
	public int Noise => _noise;
	public int Attention => _attention;
	public int Meditation => _meditation;
	public string[] EEGBandNames => _eegBandNames;

	public override void _Ready()
	{
		try
		{
#if GODOT_WINDOWS || GODOT_LINUX
			_serialPort = new SerialPort(PortName, BaudRate)
			{
				Handshake = Handshake.None,
				DataBits = 8,
				StopBits = StopBits.One,
				Parity = Parity.None,
				ReadTimeout = 100
			};
#endif
			_serialPort.Open();
			GD.Print($"Conectado ao ThinkGear na porta {PortName}");
		}
		catch (Exception ex)
		{
			GD.PrintErr("Erro na conexão serial: ", ex.Message);
		}
	}

	public override void _Process(double delta)
	{
		if (_serialPort?.IsOpen != true) 
			return;

		try
		{
			int bytesToRead = _serialPort.BytesToRead;
			if (bytesToRead > 0)
			{
				byte[] buffer = new byte[bytesToRead];
				_serialPort.Read(buffer, 0, bytesToRead);
				ProcessData(buffer);
			}
		}
		catch (TimeoutException) { }
		catch (Exception ex)
		{
			GD.PrintErr("Erro na leitura serial: ", ex.Message);
		}
	}

	private void ProcessData(byte[] data)
	{
		foreach (byte b in data)
		{
			switch (_parserState)
			{
				case ParserState.Sync1:
					if (b == 0xAA) _parserState = ParserState.Sync2;
					break;
				
				case ParserState.Sync2:
					_parserState = (b == 0xAA) ? ParserState.PayloadLength : ParserState.Sync1;
					break;
				
				case ParserState.PayloadLength:
					_payloadLength = b;
					_payloadBytes = new List<byte>(_payloadLength);
					_parserState = (_payloadLength > 0) ? ParserState.Payload : ParserState.Checksum;
					break;
				
				case ParserState.Payload:
					_payloadBytes.Add(b);
					if (_payloadBytes.Count >= _payloadLength)
					{
						_parserState = ParserState.Checksum;
					}
					break;
				
				case ParserState.Checksum:
					byte checksum = CalculateChecksum(_payloadBytes);
					if (checksum == b)
					{
						ParsePayload(_payloadBytes);
					}
					_parserState = ParserState.Sync1;
					break;
			}
		}
	}

	private byte CalculateChecksum(List<byte> payload)
	{
		byte checksum = 0;
		foreach (byte b in payload)
		{
			checksum += b;
		}
		return (byte)(~checksum & 0xFF);
	}

	private void ParsePayload(List<byte> payload)
	{
		int index = 0;
		while (index < payload.Count)
		{
			byte code = payload[index++];
			
			// Tratamento de códigos estendidos
			if (code == 0x55 && index < payload.Count)
			{
				code = payload[index++];
			}
			
			// Determina o tamanho dos dados
			int dataLength = 1;
			if (code >= 0x80) 
			{
				dataLength = payload[index++];
			}
			
			// Extrai os dados
			byte[] data = new byte[dataLength];
			int bytesToCopy = Math.Min(dataLength, payload.Count - index);
			if (bytesToCopy > 0)
			{
				Array.Copy(payload.ToArray(), index, data, 0, bytesToCopy);
			}
			index += dataLength;
			
			// Processa os pacotes de dados
			switch (code)
			{
				case 0x02:  // Poor Signal
					_noise = data.Length > 0 ? data[0] : 0;
					break;
					
				case 0x04:  // Attention
					_attention = data.Length > 0 ? (int)Math.Clamp((int)data[0], 0, 100) : 0;
					break;
					
				case 0x05:  // Meditation
					_meditation = data.Length > 0 ? (int)Math.Clamp((int)data[0], 0, 100) : 0;
					break;
					
				case 0x80:  // Raw Wave
					if (data.Length >= 2)
					{
						_rawWave = (short)((data[0] << 8) | data[1]);
					}
					break;
					
				case 0x83:  // EEG Power (pacote de 8 valores)
					if (data.Length >= 24)
					{
						for (int i = 0; i < 8; i++)
						{
							int offset = i * 3;
							uint value = (uint)((data[offset] << 16) | (data[offset+1] << 8) | data[offset+2]);
							_eegPower[i] = value;
						}
					}
					break;
			}
		}
	}

	// Métodos para acesso via GDScript
	public string GetEEGData()
	{
		StringBuilder sb = new StringBuilder();
		
		sb.AppendLine($"Raw Wave: {_rawWave}");
		
		float totalPower = _eegPower.Sum();
		
		for (int i = 0; i < 8; i++)
		{
			float percent = totalPower > 0 ? (_eegPower[i] / totalPower) * 100 : 0;
			sb.AppendLine($"{_eegBandNames[i]}: {Math.Clamp(percent, 0, 100):F1}%");
		}
		
		float noisePercent = Math.Clamp(_noise / 2f, 0, 100);
		sb.AppendLine($"Noise: {noisePercent:F1}%");
		
		noisePercent = Math.Clamp(100f - (_noise / 2f), 0, 100);
		sb.AppendLine($"Qualidade do Sinal: {noisePercent:F1}%");
		sb.AppendLine($"Atenção: {_attention}%");
		sb.AppendLine($"Meditação: {_meditation}%");
		
		return sb.ToString();
	}

	public int GetAttentionValue()
	{
		return _attention;
	}
	
	public float GetNoisePercentage()
{
	// Inverte a escala: 0-200 → 100-0%
	return Math.Clamp(100f - (_noise / 2f), 0, 100);
}


	public int GetMeditationValue()
	{
		return _meditation;
	}

	public float GetEEGBandPower(int index)
	{
		if (index >= 0 && index < 8)
			return _eegPower[index];
		return 0;
	}

	public string GetEEGBandName(int index)
	{
		if (index >= 0 && index < 8)
			return _eegBandNames[index];
		return "Unknown";
	}

	public override void _ExitTree()
	{
		_serialPort?.Close();
		base._ExitTree();
	}
}
