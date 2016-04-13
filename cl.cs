using System;
using System.Diagnostics;
using System.IO;
using System.Text;
using System.Collections.Generic;

class Cl
{
	static void eventOutputDataReceived(object sender, DataReceivedEventArgs e)
	{
	    Console.WriteLine(e.Data);
	}

	static int Main(string[] argv)
	{
		List<string> cmds = new List<string>();
		List<string> files = new List<string>();
		string options = "";
		foreach( string s in argv)
		{
			if( s.StartsWith("@") )
			{
				StreamReader sr = new StreamReader(s.Remove(0,1));
				string cmd = sr.ReadToEnd();
				sr.Close();
				cmds.AddRange(cmd.Split(' '));
			}
			else
			{
				cmds.Add(s);
			}
		}
		
		for( int i=0; i < cmds.Count; ++i )
		{
			string s = cmds[i];
			if( s.StartsWith("/") || s.StartsWith("-") )
			{
				switch( s )
				{
				case "/GS":
				case "/ZI":
				case "/Gm":
					break;
				default:
					options += s + " ";
					break;
				}
			}
			else
			{
				if( i > 0 && cmds[i-1] == "/D" )
				{
					options += s + " ";
				}
				else
				{
					//Console.WriteLine(s);
					files.Add(s);
				}
			}
		}
		options += "--driver-mode=cl";

		int exit_code = 0;
		foreach( string f in files )
		{
			string o = options + " " + f;
			Process p = new Process();
			p.StartInfo.FileName = @"include-what-you-use.exe";
			p.StartInfo.CreateNoWindow = true;
			p.StartInfo.UseShellExecute = false;
			p.StartInfo.RedirectStandardOutput = true;
			p.StartInfo.RedirectStandardError = true;
			p.StartInfo.Arguments = o;
			p.OutputDataReceived += eventOutputDataReceived;
			p.ErrorDataReceived += eventOutputDataReceived;
			
			Console.WriteLine(@"include-what-you-use " + o);
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
			if( p.ExitCode != 0 )
			{
				exit_code = p.ExitCode;
			}
		}
		return exit_code;
	}
}
