module slash;
import data;

	static Onion compress(Onion x, Onion y) {
	Onion z;
	int sum = 0;

	switch (100 * x.t + y.t) {

		case 2323:
			int[] la = new int[x.da.length];
			for (int i = 0; i < la.length; i++) {
				la[i] = cast(int)x.da[i];
				sum += la[i];
			}
			int[] s2 = y.s;
			double[] d2 = compress(la, y.da, s2[s2.length - 1]);
			s2[s2.length - 1] = sum;

			z = y;
			z.da = d2;
			z.s = s2;
			return z;

		default:
			throw new Exception("error in compress");
		}
	}

	static Onion expand(Onion x, Onion y) {
		Onion z;
		int sum = 0;

		switch (100 * x.t + y.t) {

			case 2323:
				bool[] la = new bool[x.da.length];
				for (int i = 0; i < cast(int)la.length; i++) {
					la[i] = x.da[i] == 1.0;
					sum += la[i];
				}
				int[] s2 = y.s;
				double[] d2 = expand(la, y.da, s2[s2.length - 1]);
				s2[cast(int)s2.length - 1] = cast(int)la.length;

				z = y;
				z.da = d2;
				z.s = s2;
				return z;

			default:
				throw new Exception("error in expand");
		}
	}

//	static double[] compress (double[] arg, bool[] cv, int ld) {
//		double[] r;
//		int n = 0;
//		for (int i = 0; i < cv.length; i++) if (cv[i]) n++;
//		r = new double[n * arg.length / cv.length];
//		int j = 0;
//		int k = 0;
//		for (int i = 0; i < arg.length; i++) {
//			if (j >= cv.length) j = 0;
//			if (cv[j++]) r[k++] = arg[i];
//		}
//		return r;        
//	}

	static double[] compress (int[] rv, double[] arg, int ld) {
		double[] r;
		int n = 0;
		for (int i = 0; i < rv.length; i++) n += rv[i] ;
		r = new double[n * arg.length / rv.length];
		int j = 0;
		int k = 0;
		for (int i = 0; i < arg.length; i++) {
			if (j >= rv.length) j = 0;
			if (rv[j] != 0) for(int m = 0; m < rv[j]; m++) r[k++] = arg[i];
			j++;
		}
		return r;        
	}

	static double[] expand (bool[] cv, double[] arg, int ld) {
		double[] r;
		int n = 0;
		for (int i = 0; i < cv.length; i++) if (cv[i]) n++;
		r = new double[cv.length * arg.length / n];
		int j = 0;
		int k = 0;
		for (int i = 0; i < r.length; i++) {
			if (j >= cv.length) j = 0;
			r[i] = cv[j++] ? arg[k++] : 0.0;
		}
		return r;        
	}