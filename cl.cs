using System;
using System.Diagnostics;
using System.IO;
using System.Text;

class Cl
{
	static void eventOutputDataReceived(object sender, DataReceivedEventArgs e)
	{
	    Console.WriteLine(e.Data);
	}

	static int Main(string[] argv)
	{
		string options = "";
		foreach( string s in argv)
		{
			if( s.StartsWith("@") )
			{
				StreamReader sr = new StreamReader(s.Remove(0,1));
				options += sr.ReadToEnd() + " ";
				sr.Close();
			}
			else
			{
				options += s + " ";
			}
		}
		options += "--driver-mode=cl";
		Process p = new Process();
		p.StartInfo.FileName = @"include-what-you-use.exe";
		p.StartInfo.CreateNoWindow = true;
		p.StartInfo.UseShellExecute = false;
		p.StartInfo.RedirectStandardOutput = true;
		p.StartInfo.RedirectStandardError = true;
		p.StartInfo.Arguments = options;
		p.OutputDataReceived += eventOutputDataReceived;
		p.ErrorDataReceived += eventOutputDataReceived;
		
		Console.WriteLine(@"include-what-you-use " + options);
		if( !p.Start() )
		{
			Console.WriteLine("process start failed.");
			return 1;
		}
		p.BeginOutputReadLine();
		p.BeginErrorReadLine();
		//Console.WriteLine(p.StandardOutput.ReadToEnd());
		//Console.WriteLine(p.StandardError.ReadToEnd());
		
		p.WaitForExit();
		return p.ExitCode;
	}
}
