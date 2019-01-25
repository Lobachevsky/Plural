module functions;

import data;
import parser;
import std.conv;
import xpose;
import dates;

public class fns {

	static Onion dyad0(Onion x, Onion y, double function(double, double) f ) {
		Onion r;
		switch (100 * x.t + y.t) {
			case 303:
				// r.t = 3;
				r = f(x.d, y.d);
				return r;

			case 323:
				// r.t = 23;
				r = dyad0(x.d, y.da, f);
				r.s = y.s;
				r.r = y.r;
				return r;

			case 2303:
				// r.t = 23;
				r = dyad0(x.da, y.d, f);
				r.s = x.s;
				r.r = x.r;
				return r;

			case 2323:
				// r.t = 23;
				if (lchk(x, y)) throw new Exception("length error");
				r = dyad0(x.da, y.da, f);
				r.s = x.s;
				r.r = x.r;
				return r;

			default:
				throw new Exception("syntax error 0");
				// assert (1 == 2);
		}
	}

	static double[] dyad0(double[] x, double[] y, double function(double, double) f ) {
		double[] r = x.dup;
		for (int i = 0; i < x.length; i++) {
			r[i] = f(x[i], y[i]);
		}
		return r;
	}

	static double[] dyad0(double[] x, double y, double function(double, double) f ) {
		double[] r = x.dup;
		for (int i = 0; i < x.length; i++) {
			r[i] = f(x[i], y);
		}
		return r;
	}

	static double[] dyad0(double x, double[] y, double function(double, double) f ) {
		double[] r = y.dup;
		for (int i = 0; i < y.length; i++) {
			r[i] = f(x, y[i]);
		}
		return r;
	}

	static Onion assign(Onion x, Onion y) {
		// globals.remove(x.st);
		globals[x.st] = y;
		return y;
	}

	static private bool lchk(Onion x, Onion y) {
		if (x.da.length != y.da.length) return true;
		if (x.r != y.r) return true;
		for (int i = 0; i < x.r; i++) {
			if (x.s[i] != y.s[i]) return true;
		}
		return false;
	}

	static Onion reshape(Onion x, Onion y) {
		Onion r;
		double[] t;
		string[] q;
		Day[] dy;
		int[] s;
		int p = 1;
		int l;

		if (x.t == 42) {                 // list of scalars
			l = cast(int)x.na.length;
			s = new int[l];
			for (int i = 0; i < l; i++) {
				s[i] = to!int(x.na[i].d);
				p *= s[i];
			}
		} else if (x.t == 23) {          // vector right argument
			l = cast(int)x.da.length;
			s = new int[l];
			for (int i = 0; i < l; i++) {
				s[i] = to!int(x.da[i]);
				p *= s[i];
			}
		} else {
			l = 1;
			s = new int[1];
			p = s[0] = to!int(x.d);
		}

		// r.t = 23;  // plural reshape never returns a scalar
		// r.s = s;
		// r.r = s.length;
		
		switch (y.t) {
			case 3:
				t = new double[p];
				for (int i = 0; i < p; i++) t[i] = y.d;
				r = t;
				break;

			case 5:
				q = new string[p];
				for (int i = 0; i < p; i++) q[i] = y.q;
				r = q;
				break;

			case 23:
				t = new double[p];
				int c = 0;
				for (int i = 0; i < p; i++) {
					t[i] = y.da[c++];
					if (c == y.da.length) c = 0;
				}
				r = t;
				break;

			case 25:
				q = new string[p];
				int c = 0;
				for (int i = 0; i < p; i++) {
					q[i] = y.qa[c++];
					if (c == y.qa.length) c = 0;
				}
				r = q;
				break;

			case 26:
				dy = new Day[p];
				int c = 0;
				for (int i = 0; i < p; i++) {
					dy[i] = y.dya[c++];
					if (c == y.dya.length) c = 0;
				}
				r = dy;
				break;

			default:
				throw new Exception("error in reshape");
		}
		if (l != 1) {
			r.s = s;
			r.r = cast(int)s.length;
			}
		return r;
	}

	static Onion diota(Onion x, Onion y) {
		Onion z;
		double[] t;

		switch (100 * x.t + y.t) {

			case 303:
				t = new double[to!int(y.d - x.d + 1)];
				for (int i = 0; i < t.length; i++) t[i] = x.d + i;
				z = t;
				return z;

			default:
				throw new Exception("error in iota");
		}
	}

	static Onion first(Onion x) {
		Onion z;

		switch (x.t) {
			case 3:
				return x;
			case 23:
				if (0 == x.da.length) z = 0;
				else z = x.da[0];
				return z;
			case 5:
				return x;
			case 25:
				if (0 == x.qa.length) z = "";
				else z = x.qa[0];
				return z;
			default: 
				throw new Exception("error in first");
		}
	}

	static Onion shape(Onion x) {
		double[] t = [];
		Onion z;

		switch (x.t) {
			case 3:
				z = t;
				return z;
			case 23:
				z = to!(double[])(x.s);
				return z;
			default: 
				throw new Exception("error in shape");
		}
	}










}

	


