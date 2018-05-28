module arith;

import std.math;

double fuzz = 1e-10;
int digits = 10;
bool fuzzIsZero = false;

public class Arith {

	public static double log10(double x) {
		double bias  = 5E-16;
		double t = std.math.log(x);
		return t / std.math.log(10) + signum(t) * bias;
	}

	public static double log(double x, double y) {
		double bias  = 5E-16;
		double t = std.math.log(x);
		return t / std.math.log(y) + signum(t) * bias;
	}

	public static double fmod(double x, double y) {
		if (y == 0.0) return x;
		double t = floor(x / y, 0.0000000001);
		return  x - y * t;
	}

	public static double fmod(int x, int y) {
		if (y == 0) return x;
		return  x - y * x / y;
	}

	public static bool eq(double a, double b, double c) {
		if (fuzzIsZero) return a == b;
		double t = std.math.abs(a - b);
		a = std.math.abs(a);
		b = std.math.abs(b);
		double u = std.math.fmax(a, b);
		// if (c == 0) {c = 0.0000000001;} // 1E-10
		// if (a > b) { u = a;} else {u = b;}
		return t <= c * u;
	}

	public static int floor(double a, double c ) {
		// SATN-23 rbe, dlf
		double b = std.math.abs(a);
		int r = cast(int) (signum(a) * std.math.floor(0.5 + b));         // nearest integer to a.
		if (b < 1) b = 1;
		// return ((r - a) > c * b) ? r + 1 : r;
		return ((r - a) > c * b) ? r - 1 : r;
	}

	public static int ceiling(double a , double c) {
		return -floor(-a, c);
	}

	public static bool ne(double a, double b) {
		if (fuzzIsZero) return a != b;
		else return ! eq(a, b, fuzz);
	}

	public static bool lt(double a, double b) {
		if (fuzzIsZero) return a < b;
		else return (a < b) && !eq(a, b, fuzz);
	}

	public static bool le(double a, double b) {
		if (fuzzIsZero) return a <= b;
		else return (a <= b) || eq(a, b, fuzz);
	}

	public static bool ge(double a, double b) {
		if (fuzzIsZero) return a >= b;
		else return (a >= b) || eq(a, b, fuzz);
    }
	/**
	* a < b with default comparison tolerance (1e-10)
	* @param a left argument to <
	* @param b right argument to <
	* @return true or false
	*/

	/**
	* a < b with non-default comparison tolerance
	* @param a left argument to <
	* @param b right argument to <
	* @param c comparison tolerance (i.e. 1e-16)
	* @return true or false
	*/

	public static bool eq(double a, double b) {
		if (fuzzIsZero) return a == b;
		else return eq(a, b, fuzz);
    }

	public static bool gt(double a, double b) {
		if (fuzzIsZero) return a > b;
		else return (a > b) && !eq(a, b, fuzz);
    }

	public static bool xor(double a, double b, double c) {
		return !eq(a, b, c);
	}

	public static bool and(double a, double b) {
		return eq(a, 1.0, fuzz) && eq(b, 1.0, fuzz);
	}

	public static bool and(double a, double b, double c) {
		return eq(a, 1.0, c) && eq(b, 1.0, c);
	}

	public static bool or(double a, double b, double c) {
		return eq(a, 1.0, c) || eq(b, 1.0, c);
	}

	public static bool or(double a, double b) {
		return eq(a, 1.0, fuzz) || eq(b, 1.0, fuzz);
	}

	public static bool not(double a, double c) {
		return ! eq(a, 1.0, c);
	}

	public static double rnd(double a, double b) {
		double t = std.math.pow(10, b);
		return floor(a * t, 1e-10) / t;
	}

	public static double signum(double a) {
		if (a < 0) return -1;
		if (a > 0) return 1;
		return 0;
	}
}

