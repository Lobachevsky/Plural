module util;

import std.conv;

public class util {

	public static bool validateDouble(string arg) {
		char[] c = to!(char[])(arg);
		int r = 0;
		int p = 0;
		int m = 1;
		int n;
		for (int i = c.length - 1; i > -1; i--) {
			switch(c[i]) {
				case '0': case '1': case '2': case '3': case '4':
				case '5': case '6': case '7': case '8': case '9':
					n = 1;
					break;
				case '.':
					n = 2;
					break;
				case '-':
					n = 3;
					break;
				case 'e': case 'E':
					n = 4;
					break;
				default:
					return false;
			}

			if (n != 1 || p != 1) {
				p = n;
				r = n * m + r;
				// return false if overflow
				m *= 10;
			}
		}

        if (r > 3121431) return false;

        if (r == 1 || r == 12 || r == 121 || r == 21) return true; // 1 1. 1.2 .2
        if (r == 31 || r == 312 || r == 3121 || r == 321) return true; // -1 etc.

        if (r == 141 || r == 1241 || r == 12141 || r == 2141) return true; // 1e1 1.e1 1.2e1 .2e1
        if (r == 1431 || r == 12431 || r == 121431 || r == 21431) return true; // 1e-1 1.e-1 1.2e-1 .2e-1

        if (r == 3141 || r == 31241 || r == 312141 || r == 32141) return true; // -1e1 -1.e1 -1.2e1 -.2e1
        if (r == 31431 || r == 312431 || r == 3121431 || r == 321431) return true; // -1e-1 -1.e-1 -1.2e-1 -.2e-1

        return false;
    }
}

