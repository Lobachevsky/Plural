module formatting;

import arith;
import std.conv;
import std.math;

public class Format {

	// lovingly taken from apl\11 and ported to D

	public static char[] epr0(double value) {
		int i;
		int[4] param;
		char[] r;

		epr1(value, param);                // epr1 does a sort of introspection
		i = param[1] + param[2];           // size if fp 
		if(i > digits) i += 100;
		if(param[2]) i++;
		if(i > param[0] + 5) {
			i = param[0] + 5;              // size if ep 
			param[1] = param[0];
			param[2] = -1;
		}
		if(param[3]) i++;                  // leave room for sign 
		i++;                               // leave room for leading space 
		param[0] = i;

		r = epr2(value, param);            // epr2 does the actual formatting
		return r;
	}

	private static void epr1(double d, int[] param) {
		int a;
		char[] c;
		int dp;
		int sg;

		c = ecvt(d, digits, &dp, &sg);         // initial formatting
		a = digits;                            // digits global, values 6 <= digits <= 16, typical value 10
		while(c[a - 1] == '0' && a > 1) a--;
		if(a > param[0]) param[0] = a;         // sig digits
		a -= dp;
		if(a < 0) a = 0;
		if(a > param[2]) param[2] = a;         // digits to right of dp 
		if(dp > param[1]) param[1] = dp;       // digits to left of dp 
		param[3] |= sg;                        // and sign 
	}

	private static char[] epr2(double d, int[] param) {
		int i, j;
		char[] c, e;
		int dp;
		int sg;
		char[] r;
		int t;
		int k = 0;

		c = ecvt(d, digits, &dp, &sg);
		r.length = digits + 10;
		sg = sg ? '-' : ' ';

		if(param[2] < 0) {                         // do 1.23e42 e format here
			if(param[3]) r[k++] = to!char(sg);     
			r[k++] = c[0];
			r[k++] = '.';
			for (i = 1; i < c.length; i++) r[k++] = c[i];
			r[k++] = 'e';
			dp--;

			if(dp < 0) {
				r[k++] = '-';
				dp = -dp;
			} // r[k++] = "+";
				
			e = to!(char[])(dp);
			for (i = 0; i < e.length; i++) r[k++] = e[i];   // numbers behind the e as in 1.234e307
			return r[0 .. k];
		}

		i = dp;                                      // do more ordinary 1.234 formatting here
		if(i < 0) i = 0;
		for(; i < param[1]; i++) r[k++] = ' ';
		if(param[3]) r[k++] = to!char(sg);
		for(j = 0; j < dp; j++)
			// if(c >= mc)
				// r[k++] = "0"; // else
				r[k++] = c[j];
		for(i = 0; i < param[2]; i++) {
			if(i == 0 && k == 0) r[k++] = '0';
			if(i == 0) r[k++] = '.';
			if(dp < 0) {
				r[k++] = '0';
				dp++;
			} else
				// if(c >= mc)
					// r[k++] = '0'; // else
					r[k++] = c[j++]; // c[i + j];
		}
		return r[0 .. k];
	}

	/* ecvt, fcvt -- convert floating-point numbers to ascii	-*- C -*-	*/

	/* Copyright (c) 2009 Ian Piumarta
	 * 
	 * All rights reserved.
	 * 
	 * Permission is hereby granted, free of charge, to any person obtaining a copy
	 * of this software and associated documentation files (the 'Software'), to
	 * deal in the Software without restriction, including without limitation the
	 * rights to use, copy, modify, merge, publish, distribute, and/or sell copies
	 * of the Software, and to permit persons to whom the Software is furnished to
	 * do so, provided that the above copyright notice(s) and this permission
	 * notice appear in all copies of the Software.  Inclusion of the above
	 * copyright notice(s) and this permission notice in supporting documentation
	 * would be appreciated but is not required.
	 *
	 * THE SOFTWARE IS PROVIDED 'AS IS'.  USE ENTIRELY AT YOUR OWN RISK.
	 */

	/* This file provides replacements for the functions ecvt() and fcvt() that
	 * were deprecated in POSIX.  The interface and behaviour is identical
	 * to the functions that they replace (and faster too, at least on my machine).
	 * They have been tested on 32- and 64-bit machines of both orientations.
	 * 
	 * For details on the use of these functions, see your ecvt(3) manual page.  If
	 * you don't have one handy, there might still be one available here:
	 * http://opengroup.org/onlinepubs/007908799/xsh/ecvt.html
	 */


	private static char[] convert(double value, int ndigit, int *decpt, int *sign, int fflag) {
		char[] buf;
		int bufsize = 0;
		union lf {ulong l; double f;} 
		lf x;
		x.f = value;
		int exp2 = cast(int)(0x7ff & (x.l >> 52)) - 1023;
		ulong mant = x.l & 0x000fffffffffffffUL;
		*sign = x.l >> 63;
		if (*sign) value = -value;                  // value always positive
		if (exp2 == 0x400) {
			*decpt = 0;
			buf = mant ? "nan".dup : "inf".dup;
			return buf;
		}
		int exp10 = (value == 0) ? !fflag : cast(int)ceil(log10(value));
		if (exp10 < -307) exp10 = -307;	            // otherwise math.pow() overflow
		value *= pow(10.0, -exp10);
		if (value) {
			while (value <  0.1) { 
				value *= 10;  
				--exp10; 
			}
			while (value >= 1.0) { 
				value /= 10;  
				++exp10; 
			}
		}			

		assert(value == 0 || (0.1 <= value && value < 1.0));

		if (fflag) {
			if (ndigit + exp10 < 0) {
				*decpt= -ndigit;
				buf.length = 0;
				return buf;
			}
			ndigit += exp10;
		}
		*decpt= exp10;
		if (bufsize < ndigit + 1) {              // was 2 to accommodate trailing 0
			bufsize = ndigit + 1;
			buf.length = bufsize;
		}
		int ptr = 1;

		while (ptr <= ndigit) {
			double i;
			value = value * 10;
			i = floor(value);                     // always positive
			value = value - i;
			// value = modf(value * 10, &i);      // no math.modf for double, using floor
			buf[ptr++] = to!char('0' + cast(int)i);
		}

		if (value >= 0.5)
			while (--ptr && ++buf[ptr] > '9')
				buf[ptr]= '0';

		if (ptr) {
			return buf[1 .. $];
		}

		if (fflag) {
			++ndigit;
			++*decpt;
		}

		buf[0]= '1';
		return buf;
	}

	private static char[] ecvt(double value, int ndigit, int *decpt, int *sign) { 
		return convert(value, ndigit, decpt, sign, 0); 
	}

	private static char[] fcvt(double value, int ndigit, int *decpt, int *sign) { 
		return convert(value, ndigit, decpt, sign, 1); 
	}
}
