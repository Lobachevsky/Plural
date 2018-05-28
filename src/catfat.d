module catfat;

import data;
import std.math;

	static Onion cat(Onion x, Onion y) {
		Onion z;

		switch (100 * x.t + y.t) {

			case 303:
				z = [x.d, y.d];
				break;

			case 323:
				z = x.d ~ y.da;
				break;

			case 2303:
				z = x.da ~ y.d;
				break;

			case 2323:
				z = x.da ~ y.da;
				break;

			default:
				throw new Exception("cat gone too far");
		}

		z.s = [z.da.length];
		z.r = z.s.length;
		return z;
	}

	static Onion lam(Onion x, Onion y) {
		Onion z;

		switch (100 * x.t + y.t) {

			case 303:
				z = [x.d, y.d];
				break;

			case 323:
				z = x.d1v(y.da.length).da ~ y.da;
				z.s = 2 ~ y.s;
				z.r = z.s.length;
				break;

			case 2303:
				z = x.da ~ y.d1v(x.da.length).da;
				z.s = 2 ~ x.s;
				z.r = z.s.length;
				break;

			case 2323:
				z = x.da ~ y.da;
				z.s = 2 ~ y.s;
				z.r = z.s.length;
				break;

			default:
				throw new Exception("lam gone too far");
		}
		return z;
	}

	static Onion ravel(Onion x) {
		Onion z;

		switch (x.t) {

			case 3:
				z = [x.d];
				break;

			case 23:
				z = x.da.dup;
				break;

			default:
				throw new Exception("ravel gone too far");
		}

		z.s = [z.da.length];
		z.r = z.s.length;
		return z;
	}

	public static double[] bat (double[] argl, double[] argr) {
		double[] r = new double[argl.length + argr.length];
		int c = 0;
		for (int i = 0; i < argl.length; i++) r[c++] = argl[i];
		for (int i = 0; i < argr.length; i++) r[c++] = argr[i];
		return r;        
	}

	public static double[] bat (double argl, double[] argr) {
		double[] r = new double[2 * argr.length];
		int c = 0;
		for (int i = 0; i < argr.length; i++) r[c++] = argl;
		for (int i = 0; i < argr.length; i++) r[c++] = argr[i];
		return r;        
	}

	public static double[] bat (double[] argl, double argr) {
		double[] r = new double[2 * argl.length];
		int c = 0;
		for (int i = 0; i < argl.length; i++) r[c++] = argl[i];
		for (int i = 0; i < argl.length; i++) r[c++] = argr;
		return r;        
	}

	public static double[] bat (double arg1, double arg2) {
		return [arg1, arg2];
	}
