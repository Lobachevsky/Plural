module data;

import std.conv;
import core.sys.posix.stdlib;
import formatting;

struct Onion {
	union {
		int i;
		double d;
		char c;
		bool b;
		int[] ia;
		double[] da;
		char[] ca;
		bool[] ba;
		Onion[] na;
	}
	int t;
	int r;
	int[] s;
	string st;

	string toString() {
		string z = "";
		switch(t) {
			case 1: return to!string(b);
			case 2: return to!string(i);
			case 3: return to!string(Format.epr0(d)); // to!string(d);
			case 4: return to!string(c);

			case 23:

				switch(r) {

					case 0:
						return to!string(da[0]);  // depth 1 scalar

					case 1:
						// for(int i = 0; i < da.length; i++) z = z ~ to!string(da[i]) ~ " ";
						for(int i = 0; i < da.length; i++) z = z ~ to!string(Format.epr0(da[i])) ~ " ";
						break;

					case 2:
						int l = s[1];
						for(int i = 0; i < da.length; i++) {
							if (i != 0 && 0 == i % l) z = z ~ "\n";
							// z = z ~ to!string(da[i]) ~ " ";
							z = z ~ to!string(Format.epr0(da[i])) ~ " ";
						}
						break;

					default:
						int l = s[$ - 1];
						int p = l * s[$ - 2];
						for (int i = 0; i < da.length; i++) {
							if (i != 0 && 0 == i % l) z = z ~ "\n";
							if (i != 0 && 0 == i % p) z = z ~ "\n";
							// z = z ~ to!string(da[i]) ~ " ";
							z = z ~ to!string(Format.epr0(da[i])) ~ " ";
						}
						break;
				}
				return z;

			default: return "??? " ~ st ~ " " 
				~ to!string(t) ~ " " 
				~ to!string(b) ~ " " 
				~ to!string(i) ~ " " 
				// ~ to!string(d) ~ " " 
				~ to!string(Format.epr0(d)) ~ " " 
				~ to!string(c) ~ " ";
		}
	}

	void opAssign(double v) {
		d = v;
		t = 3;
		r = 0;
		s = new int[0];
		st = "";
	}

	void opAssign(double[] v) {
		da = v;
		t = 23;
		r = 1;
		// s = new int[1];
		// s[0] = v.length;
		s = [cast(int)v.length];
		st = "";
	}

	// Depth-1 scalar
	Onion d1s() {
		Onion r;
		r.da = [d];
		r.s = new int[0];
		r.r = 0;
		r.t = t + 20;
		r.st = "";
		return r;
	}

	// Depth-1 vector
	Onion d1v(int n) {
		Onion r;
		double[] z = new double[n];
		for (int i = 0;i < n; i++) z[i] = d;
		r.da = z;
		r.s = [n];
		r.r = 1;
		r.t = t + 20;
		r.st = "";
		return r;
	}


}