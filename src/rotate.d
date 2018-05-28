module rotate;
import std.conv;
import data;

static Onion mreverse(Onion x) {
	Onion z;

	switch (x.t) {

		case 23:
			z.da = reverse(x.da);
			z.s = x.s;
			z.t = x.t;
			z.r = x.r;
			return z;

		default:
			throw new Exception("Reverse gone too far");
	}
}

private double[] reverse(double[] arg) {
	double[] r = arg.dup;
	int t = r.length - 1;
	for (int i = 0; i < r.length / 2; i++) {
		double s = r[i];
		r[i] = r[t - i];
			r[t - i] = s;
		}
	return r;
}

static Onion drotate(Onion x, Onion y) {
	Onion z;

	switch (100 * x.t + y.t) {

		case 323:
			z.da = rotate(to!int(x.d), y.da);
			z.s = y.s;
			z.t = y.t;
			z.r = y.r;
			return z;

		default:
			throw new Exception("Rotate gone too far");
	}
}

private double[] rotate(int n, double[] arg) {
	int l = arg.length;
	double[] r = new double[l];
	for (int i = 0; i < l; i++) {
		r[i] = arg[(n + i) % l];
	}
	return r;
}


