module encdec;

import arith;
import data;

	static Onion encode(Onion x, Onion y) {
		Onion z;

		if (y.t == 3) y = y.d1s();

		switch (100 * x.t + y.t) {

			case 2323:
				z = enc(x.da, y.da);
				z.s = x.da.length ~ y.s;
				z.r = z.s.length;
				z.t = y.t;
				return z;

			default:
				throw new Exception("encode gone too far");
		}
	}

	static Onion decode(Onion x, Onion y) {
		Onion z;

		if (x.t == 3) x = x.d1v(y.s[0]);

		switch (100 * x.t + y.t) {

			case 2323:
				z = dec(x.da, y.da);
				z.s = 1 == y.s.length ? [] : y.s[1 .. $ - 1];
				z.r = z.s.length;
				z.t = y.t;
				return z;

			default:
				throw new Exception("decode gone too far");
		}
	}

	public static double[] enc (double[] argl, double[] argr) {
		int ll = argl.length;
		int lr = argr.length;
		double[] r = new double[ll * lr];
		double[] t = argr.dup();

		for (int m = ll - 1; m >= 0; m--) {
			int j = lr * m;
			for (int i = 0; i < lr; i++) {
				r[j + i] = Arith.fmod(t[i], argl[m]); 
				t[i] = Arith.floor(t[i] / argl[m], 0.0);
			}
		}
		return r;        
	}

	public static double[] dec (double[] argl, double[] argr) {
		int ll = argl.length;
		int lr = argr.length;
		double[] r = new double[lr / ll];
		double[] t = argr.dup();
		double[] u = pow(argl);

		for (int i = 0; i < r.length; i++) r[i] = 0.0;

		for (int m = ll - 1; m >= 0; m--) {
			int j = lr / ll * m;
			for (int i = 0; i < r.length; i++) r[i] += argr[j + i] * u[m];
		}
		return r;        
	}

	public static double[] pow(double[] arg) {
		double[] r = arg.dup();
		double a = 1.0;
		double b;
		for (int i = r.length - 1; i >= 0; i--) {
			b = r[i];
			r[i] = a;
			a *= b;
		}
		return r;
	}
