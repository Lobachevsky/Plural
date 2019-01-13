module index;

import data;
import std.conv;
import parser;

private int[] iop(int mult, double[] vec2, int[] vec1) {
	int l1 = cast(int)vec1.length;
	int l2 = cast(int)vec2.length;
	int[] r = new int[l1 * l2];
	int c = 0;
	for(int i = 0; i < l2; i++) {
		int t = cast(int)vec2[i] * mult;
		for(int j = 0; j < l1; j++) {
			r[c++] = t + vec1[j];
		}
	}
	return r;
}

private int[] powr(int[] pv) {
	int l = cast(int)pv.length;
	int[] r = new int[l];
	if (l == 0) return r;
	r[0] = 1;
	for (int i = 1; i < pv.length; i++) {
		r[i] = r[i - 1] * pv[$ - i];
	}
	return r;
}

private int[] idxvec(Onion x, Onion y) {
	int[] pv = powr(x.s);                     // power vector (strides)

	int[] tt;                                 // get the index vector of the last coordinate
	if (y.na[$ - 1].t == 3) tt = [cast(int)y.na[$ - 1].d];   // scalar
	else tt = intvec(y.na[$ - 1].da);                        // aud    

	for (int i = 1; i < y.na.length; i++) {   // outer product multiply with successive coordinates, go backwards
		if(y.na[$ - i - 1].t == 3) tt = iop(pv[i], [y.na[$ - i - 1].d], tt);
		else tt = iop(pv[i], y.na[$ - i - 1].da, tt);
	}
	return tt;
}

private int product(int[]asv) {
	int p = 1;
	for (int i = 0; i < asv.length; i++) p *= asv[i];   // product of shapes (scalar is 1)
	return p;
}

static Onion idx(Onion x, Onion y) {
	Onion r;
	switch (100 * x.t + y.t) {
		case 2303:
			// r.t = 3;
			r = x.da[to!int(y.d)];
			return r;

		case 2323:
			// r.t = 23;
			double[] t = new double[y.da.length];
			for (int i = 0; i < t.length; i++) {
				t[i] = x.da[to!int(y.da[i])];
			}
			r = t;
			return r;

		case 2342:
			int[] sv = new int[0];                    // shape vector for determining shape at the end
			int[] asv = new int[0];                   // shape vector for determining actual strides
			for (int i = 0; i < y.na.length; i++) {   // combined shapes of indexes
				if (y.na[i].t == 23) {
					sv = sv ~ y.na[i].s;
					asv = asv ~ y.na[i].s;
				} else {
					asv = asv ~ 1;                    // scalar shape is one, for these purposes
				}
			}
			int p = product(asv);                     // product of shapes (scalar is 1)
			int[] tt = idxvec(x, y);                  // get the index vector of the last coordinate
			double[] tv = new double[p];              // answer goes here
			for (int i = 0; i < tt.length; i++) {
				tv[i] = x.da[tt[i]];
			}
			if (sv.length == 0) {                     // prepare result
				r.d = tv[0];                          // true scalar data
				r.t = 3;                              // floating scalar data type
				r.s = [];                             // shape vector empty for a true scalar
				r.r = 0;                              // scalar rank zero
			} else {
				r.s = sv;                             // aud
				r.da = tv;                            // the data
				r.t = 23;                             // floating aud data type
				r.r = cast(int)sv.length;                      // rank is length of the shape vector
			}
			return r;

		default:
			throw new Exception("error in indexing");
	}
}

static Onion idxasgn(Onion x, Onion y, Onion z) {
	Onion r = z;
	int[] sv = new int[0];                    // shape vector for determining shape at the end
	int[] asv = new int[0];                   // shape vector for determining actual strides
	switch (10000 * x.t + 100 * y.t + z.t) {
		case 230303:  // x[s] := s
			x.da[to!int(y.d)] = z.d;
			globals[x.st] = x;
			return r;

		case 232303:  // x[v] := s
			for (int i = 0; i < y.da.length; i++) {
				x.da[to!int(y.da[i])] = z.d;
			}
			globals[x.st] = x;
			return r;

		case 232323:   // x[s] := v   
			for (int i = 0; i < y.da.length; i++) {
				x.da[to!int(y.da[i])] = z.da[i];
			}
			globals[x.st] = x;
			return r;

		case 234223: // x[s1, s2, s3] := m
			for (int i = 0; i < y.na.length; i++) {   // combined shapes of indexes
				if (y.na[i].t == 23) {
					sv = sv ~ y.na[i].s;
					asv = asv ~ y.na[i].s;
				} else {
					asv = asv ~ 1;                    // scalar shape is one, for these purposes
				}
			}
			int p = product(asv);                     // product of shapes (scalar is 1)
			int[] tt = idxvec(x, y);                  // get the index vector of the last coordinate
			for (int i = 0; i < tt.length; i++) {
				x.da[tt[i]] = z.da[i];
			}
			// r = z.da;
			globals[x.st] = x;
			return r;

		case 234203: // x[s1, s2, s3] := s
			for (int i = 0; i < y.na.length; i++) {   // combined shapes of indexes
				if (y.na[i].t == 23) {
					sv = sv ~ y.na[i].s;
					asv = asv ~ y.na[i].s;
				} else {
					asv = asv ~ 1;                    // scalar shape is one, for these purposes
				}
			}
			int p = product(asv);                     // product of shapes (scalar is 1)
			int[] tt = idxvec(x, y);                  // get the index vector of the last coordinate
			for (int i = 0; i < tt.length; i++) {
				x.da[tt[i]] = z.d;
			}
			// r = z.d;
			globals[x.st] = x;
			return r;

		default:
			throw new Exception("error in index assignment");
	}
}

public int[] intvec(double[] arg) {
	int[] r = new int[arg.length];
	for (int i = 0; i < arg.length; i++) r[i] = cast(int)arg[i];
	return r;
}

