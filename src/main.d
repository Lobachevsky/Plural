import std.stdio;
import std.conv;
import std.string;
import std.array;
import lexical;
import parser;
import data;
import arith;
import util;

// public class PluralRepl {

	int main(string[] argv) {
		string result;
        string EXIT_COMMAND = "#off\n";
		writeln("Plural Interpreter Version 2018.04.04");
		writeln("Enter '#off' to quit");

		parsermode = 2;

		while (true) {

			write("> ");
			string input = stdin.readln();
			input = syscommand(input);
			if (input == "") continue;
			if (input == "\b") return(42);
			result = exec(input, globals);
			writeln(result);
		}
	}

	string exec(string expr, Onion[string] globals) {
		try {
			Onion r = pratt.parse(expr, globals);
			return r.toString();
		} catch (Exception e) {
			auto l1 = line;
			auto l2 = tptr;
			auto l3 = e;
			writeln(e.msg);
			writeln(join(line[0..tptr-2], " ") ~ " (error) " ~ join(line[tptr-2..$-1], " "));
			return "";
		}
	}

	string syscommand(string expr) {
		string t = expr.strip();
		if (0 == t.length) return "";
		if ('#' != t[0]) return expr;

		string[] l = t.split(" ");

		switch (l[0]) {

			case "#off":
				writeln("Exiting Plural");
				return("\b");

			case "#parse":
				if (l.length == 1) {
					writeln("is " ~ ((parsermode == 1) ? "ltor" : "iverson"));
				} else {
					switch(l[1]) {
						case "1":
						case "ltor":
							parsermode = 1;
							break;
						case "2":
						case "iverson":
							parsermode = 2;
							break;
						default:
							writeln("incorrect parse command");
					}
				}
				break;

			case "#vars":
				write("vars: (" ~ to!string(globals.length) ~ ") \n");
				foreach(k; globals.byKey()) {
					write(k ~ " ");
					write(globals[k].toString());
					write("\n");
				}
				break;

			case "#fuzz":
				if (l.length == 1) {
					if (fuzzIsZero) {
						writeln("is Zero");
					} else {
						writeln("is " ~ to!string(fuzz));
					}
				} else {
					if (util.util.validateDouble(l[1])) {
						double f = to!double(l[1]);
						if (f < 0 || f > 1e-5) {
							writeln("error: 0 <= fuzz <= 1e-5");
						} else {
							fuzz = f;
							fuzzIsZero = f == 0;
						} 
					} else {
						writeln("incorrect fuzz argument");
					}
				}
				break;

			case "#digits":
				if (l.length == 1) {
						writeln("is " ~ to!string(digits));
					
				} else {
					if (util.util.validateDouble(l[1])) {
						double f = to!double(l[1]);
						if (f < 1 || f > 34) {
							writeln("error: 1 <= fuzz <= 34");
						} else {
							fuzz = f;
							fuzzIsZero = f == 0;
						} 
					} else {
						writeln("incorrect digits argument");
					}
				}
				break;

			default:
				writeln("incorrect command");
		}
		return "";
	}


	

