module xpose;

import data;

/*

public class FFred {

    public int r;
    public int l;
    public int[] s;
    public double[] d;

    public FFred(final int s[], final double d[]) {
        int i = 0;
        int l = 1;
        r = s.length;
        this.s = new int[r];
        for (i = 0; i < s.length; i++) {
            l = l * s[i];
            this.s[i] = s[i];
        }
        this.l = l;

        this.d = new double[l];
        for (i = 0; i < l; i++) {
            this.d[i] = d[i % d.length];
        }
    }

    public FFred(final int s[], final double d) {
        int i = 0;
        int l = 1;
        r = s.length;
        this.s = new int[r];
        for (i = 0; i < s.length; i++) {
            l = l * s[i];
            this.s[i] = s[i];
        }
        this.l = l;

        this.d = new double[l];
        for (i = 0; i < l; i++) {
            this.d[i] = d;
        }
    }

    public FFred(final int s, final double d[]) {
        int i = 0;
        final int l = s;
        r = 1;
        this.l = s;
        this.s = new int[1];
        this.s[0] = s;
        this.d = new double[l];
        for (i = 0; i < l; i++) {
            this.d[i] = d[i % d.length];
        }
    }

    public FFred(final int s, final double d) {
        int i = 0;
        final int l = s;
        r = 1;
        this.l = s;
        this.s = new int[1];
        this.s[0] = s;
        this.d = new double[l];
        for (i = 0; i < l; i++) {
            this.d[i] = d;
        }
    }

    public double[] data() {
        return d;
    }

    public double first() {
        return d[0];
    }

    public double last() {
        return d[d.length - 1];
    }

    public int rank() {
        return r;
    }

    public int length() {
        return l;
    }

    /*
	* public FFred shape() { return new IFred(s.length, s); }
	*/

    static Onion transpose(Onion a) {
		Onion z;
        int[] s1 = a.s;
        int[] s2 = s1.dup();
        for (int i = 0; i < s1.length; i++) {
            s2[s2.length - i - 1] = s1[i];
        }
        int[] idx = xpose(s2, a.s);

        double[] d = a.da.dup();
        for (int i = 0; i < d.length; i++) {
            d[i] = a.da[idx[i]];
        }
        int[] s3 = s2.dup();
        for (int i = 0; i < a.da.length; i++) {
            s3[i] = a.s[s2[i]];
        }

		z = d;
		z.s = s3;

        return z;
    }

    int[] xpose(int[] arg, int[] dim) {
        int[] p = new int[dim.length];
        p[0] = 1;
        for (int i = 0; i < p.length - 1; i++) {
            p[i + 1] = p[i] * dim[dim.length - i - 1];
        }

        int j = 1;
        int t = 1;
        for (int i = 0; i < dim.length; i++) {
            t = t * dim[i];
        }
        int[] z = new int[t];

        for (int c = arg.length - 1; c >= 0; c--) {
            int s = -1;
            for (int i2 = 0; i2 < arg.length; i2++) {
                s = i2;
                if (c == arg[i2]) {
                    break;
                }
            }
            int k = j * dim[s];

            for (int l = 1; l < k; l++) {
                z[l] = p[p.length - s - 1] * (l / j) + z[l % j];
            }
            j = k;
        }
        return z;
    }

	static Onion dtranspose(Onion x, Onion y) {
		Onion z;

		switch (100 * x.t + y.t) {

			case 2323:
				int[] la = new int[x.da.length];
				for (int i = 0; i < la.length; i++) {
					la[i] = cast(int)x.da[i];
				}
				int[] t = xpose(la, y.s);
				double[] d2 = new double[y.da.length];
				for(int i = 0; i < d2.length; i++) {
					d2[i] = y.da[t[i]];
				}
				int[] s2 = new int[y.s.length];
				for(int i = 0; i < s2.length; i++) {
					s2[la[i]] = y.s[i];
				}
				z = d2;
				z.s = s2;
				z.t = y.t;
				z.r = y.r;
				return z;

			default:
				throw new Exception("Transpose gone too far");
		}

	}
