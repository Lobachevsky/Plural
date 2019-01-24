module lexical;

import std.conv;
import dates;

public class lex {

	// let's get lexical

	public static int ptr;
	public static string[] split(string arg) {

	    string[] r = new string[arg.length + 1];
		char sep = 7;

	    int c, d;
	    string s;
	    bool n0, n1;
		bool mo0, mo1;
		bool do0, do1, do2;
		// bool s0, s1;
	    d = 0;
	    arg = ' ' ~ arg ~ '\n';
	    ptr = 1;
	    n0 = false;
		mo0 = false;

	    while (ptr < arg.length) {
	        c = ptr;
	        s = to!string(arg[c - 1]);
	        n1 = false;
			// s1 = false;
	        switch (s) {
	            case " ": case "\n":
	                ptr = c + 1;
	                s = "";
	                break;
	            case "/":
	                s = comment(arg);
	                if (s == "") {
						s = fun(arg);
	                }
	                break;
	            case "\"":
					// s1 = true;
					n1 = true;
	                s = quote(arg, "\"");
	                break;
	            case "'":
	                s = quote(arg, "'");
	                break;
	            case "_": 
	            case "a": case "b": case "c": case "d": case "e":
	            case "f": case "g": case "h": case "i": case "j":
	            case "k": case "l": case "m": case "n": case "o":
	            case "p": case "q": case "r": case "s": case "t":
	            case "u": case "v": case "w": case "x": case "y":
	            case "z":
	            case "A": case "B": case "C": case "D": case "E":
	            case "F": case "G": case "H": case "I": case "J":
	            case "K": case "L": case "M": case "N": case "O":
	            case "P": case "Q": case "R": case "S": case "T":
	            case "U": case "V": case "W": case "X": case "Y":
	            case "Z":
	                s = alpha(arg);
	                break;
	            case "-":
	                n1 = true;
	                s = num2(arg);
	                if (s == "") s = num1(arg);
	                if (s == "") {
	                    s = fun(arg);
	                    n1 = false;
	                }
	                break;
	            case "0": case "1": case "2": case "3": case "4":
	            case "5": case "6": case "7": case "8": case "9":
	                n1 = true;
					s = date(arg);
	                if (s == "") s = num2(arg);
	                if (s == "") s = num1(arg);
	                break;
	            case "+": case "*": case "%": case "\\": 
	            case "<": case ">": case "=": case "~":
				case "$": case ".": case "@": case "^":
	                s = fun(arg);
	                break;
	            case ":":
	                s = asgn(arg);
					if (s == "") s = fun(arg);
	                break;
	            case "(": case ")": case "[": case "]": case "{": case "}":
	                s = to!string(arg[c - 1]);
	                ptr = c + 1;
	                break;
	            case ";": case "&": case "`": case "´": case ",":
	            case "¨": case "|":
	                s = to!string(arg[c - 1]);
	                ptr = c + 1;
	                break;
	            default:
	                assert(1 == 2);
	                break;
	        }

	        if (s != "") {
				// if ((n0 && n1) || (s0 && s1)) r[d - 1] = r[d - 1] ~ " " ~ s;
				if (n0 && n1) r[d - 1] = r[d - 1] ~ sep ~ s;
	            else {
					r[d] = s;
					d = d + 1;
	            }
	        	// r[d++] = s;

	            n0 = n1;
				// s0 = s1;
	        }
	    }

	    r[d] = "\n";

	    return r;

	}

	private static string quote(string arg, string k) {

		int b, c;
		bool qt;
		qt = true;
		b = ptr;
		c = b + 1;

		while (qt || k == to!string(arg[c - 1])) {
			if (k == to!string(arg[c - 1])) qt = !qt;
			c = c + 1;
		}
		ptr = c;
		return arg[b - 1 .. c - 1];
	}

	private static string alpha(string arg) {

    	int b, c, d;

    	b = ptr;
    	c = b;
    	d = arg[c - 1];

    	while (d == 95 || (d >= 97 && d <= 122) || (d >= 65 && d <= 90) || (d >= 48 && d <= 57)) {
    		c = c + 1;
    		d = arg[c - 1];
    	}
    	ptr = c;
    	return arg[b - 1 .. c - 1];
	}

	private static string fun(string arg) {

	    int c, d;
	    string s1, s2;
	    string r;
	    c = ptr;
	    d = 1;
	    s1 = to!string(arg[c - 1]);
	    s2 = to!string(arg[c]);
	    r = s1;

	    switch (s1) {
	        case "+":
				switch (s2) {
					case "&":
						d = 2;
						break;
					default:
						break;
				}
				break;
	        case "-":
				switch (s2) {
					case "&":
						d = 2;
						break;
					default:
						break;
				}
				break;
	        case "*":
	            switch (s2) {
	                case "*":	case "$":	case "&":
	                    d = 2;
	                    break;
	                default:
	                	break;
	            }
				break;

			case ".":
				switch(s2) {
					case ".":
						d = 2;
						break;
					default:
						break;
				}
				break;

			case ":":	case "%":	case "/":	case "\\":	case "$":	case "^":
				break;
	        case "<":
	            switch (s2) {
	                case "=": case ">": case ":":
	                    d = 2;
	                    break;
	                default:
	                	break;
	            }
	            break;
	        case ">": 
	            switch (s2) {
	                case "=": case ":":
	                    d = 2;
	                    break;
	                default:
	                	break;
	            }
	            break;
	        case "=":
	        case "~":
	            switch (s2) {
	                case "=": case "&": case "|":
	                    d = 2;
	                    break;
	                default:
	                	break;
	            }
				break;

			case "@":
				switch (s2) {
					case "\\": case "|": case "-":
						d = 2;
						break;
					default:
						break;
				}
				break;


	        default:
	        	assert(1 == 2);
	        	break;
	    }

	    if (d == 2) r = s1 ~ s2;
	    ptr = c + d;
	    return r;
	}

	private static string asgn(string arg) {

	    int c, d;
	    string s1, s2;
	    string r;

	    c = ptr;
	    d = 0;
	    s1 = to!string(arg[c - 1]);
	    s2 = to!string(arg[c]);
	    r = s1;

	    switch (s1) {

	        case ":":
	            switch (s2) {
	                case "=":
	                    d = 2;
	                    break;
	                default:
						d = 0;
						r = ""; // assignment or nothing
	                	break;
	            }
				break;

	        default:
	            // assert(1 == 2);
	            break;
	    }
	    if (d == 2) r = s1 ~ s2;
	    ptr = c + d; 
	    return r;
	}

	private static string comment(string arg) {

	    int c, d;
		string r;
	    r = "";
	    c = ptr;
	    if (arg[c] != '/') {
	        c = c + 0;
	        return r;
	    }

	    d = cast(int)arg.length - 1;
	    r = arg[c - 1 .. d];
	    ptr = d + 1;
	    return r;
	}

	private static string num1(string arg) {

		int i, l, c, s, p, r;

	    l = cast(int)arg.length;
	    p = ptr;
	    s = ptr;
	    r = 0;
	    string num1 = "";

	    c = arg[p - 1];
	    if (c == 45) {
	        p = p + 1;
	        r = r + 1;
	    }

	    c = arg[p - 1];
	    if (c < 48 || c > 57) return num1;
	    p = p + 1;
	    r = r + 1;

	    for (i = p; i <= l; i++) {
	    	c = arg[i - 1];
	        if (c < 48 || c > 57) break;
	        p = p + 1;
	        r = r + 1;
	    }

	    num1 = arg[s - 1 .. p - 1]; //
	    ptr = s + r;

	    if (p > l) return num1;

	    c = arg[p - 1];
	    if (c != 46) return num1;
	    p = p + 1;
	    r = r + 1;

	    if (p > l) return num1;

	    c = arg[p - 1];
	    if (c < 48 || c > 57) return num1;
	    p = p + 1;
	    r = r + 1;

	    for (i = p; i <= l; i++) {
	    	c = arg[i - 1];
	        if (c < 48 || c > 57) break;
	        p = p + 1;
	        r = r + 1;
	    }

	    num1 = arg[s - 1 .. p - 1]; //
	    ptr = s + r;
	    return num1;
	}

	private static string num2(string arg) {

		int i, l, c, s, p, r;
		l = cast(int)arg.length;
	    p = ptr;
	    s = ptr;
	    r = 0;
	    string num2 = "";

	    c = arg[p - 1];
	    if (c == 45) {
	        p = p + 1;
	        r = r + 1;
	    }

	    c = arg[p - 1];
	    if (c < 48 || c > 57) return num2;
	    p = p + 1;
	    r = r + 1;

	    for (i = p; i <= l; i++) {
	        c = arg[i - 1];
	        if (c < 48 || c > 57) break;
	        p = p + 1;
	        r = r + 1;
	    }

	    if (p > l) return num2;

	    c = arg[p - 1];
		// if (c == 101) {       // check for e
			if (c == 46) {
	    		p = p + 1;
	    		r = r + 1;
			}

			if (p > l) return num2;

			c = arg[p - 1];
			if (c < 48 || c > 57) return num2;
			p = p + 1;
			r = r + 1;

			for (i = p; i <= l; i++) {
				c = arg[i - 1];
				if (c < 48 || c > 57) break;
				p = p + 1;
				r = r + 1;
			}

			if (p > l) return num2;
			c = arg[p - 1];
		// }
		if (c != 101) return num2;
		
	    p = p + 1;
	    r = r + 1;

	    c = arg[p - 1];
	    if (c == 45) {
	        p = p + 1;
	        r = r + 1;
	    }

	    if (p > l) return num2;

	    c = arg[p - 1];
	    if (c < 48 || c > 57) return num2;
	    p = p + 1;
	    r = r + 1;

	    for (i = p; i <= l; i++) {
	        c = arg[i - 1];
	        if (c < 48 || c > 57) break;
	        p = p + 1;
	        r = r + 1;
	    }

	    num2 = arg[s - 1 .. p - 1]; //
	    ptr = s + r;
	    return num2;
	}

	private static string date(string arg) {
		if (arg.length < ptr + 10) return "";
		int p = ptr - 1;
		if (arg[p + 4] != '.') return "";
		if (arg[p + 7] != '.') return "";

		int e = (arg[p] - 48) * 10000000;

		int d = arg[p + 1];
		if (d < 48 || d > 57) return "";
		e += (d - 48) * 1000000;

		d = arg[p + 2];
		if (d < 48 || d > 57) return "";
		e += (d - 48) * 100000;

		d = arg[p + 3];
		if (d < 48 || d > 57) return "";
		e += (d - 48) * 10000;

		d = arg[p + 5];
		if (d < 48 || d > 57) return "";
		e += (d - 48) * 1000;

		d = arg[p + 6];
		if (d < 48 || d > 57) return "";
		e += (d - 48) * 100;

		d = arg[p + 8];
		if (d < 48 || d > 57) return "";
		e += (d - 48) * 10;

		d = arg[p + 9];
		if (d < 48 || d > 57) return "";
		e += d - 48;

		if (!Day.isValid(e)) return "";
		string r = arg[p .. p + 10];
		ptr += 10;

		return r;
	}

	// public static string mid(final string arg, final int a0, final int a1) {
	// 	return arg.substring(a0-1, a0+a1-1);
	// }

	unittest
	{
		string[] a = lex.split("42+0+rat=42.7+4.2e1/-76..3");
		assert(a.length == 13);
		assert(a[0] == "42");
		assert(a[1] == "+");
		assert(a[2] == "0");
		assert(a[3] == "+");
		assert(a[4] == "rat");
		assert(a[5] == "=");
		assert(a[6] == "42.7");
		assert(a[7] == "+");
		assert(a[8] == "4.2e1");
		assert(a[9] == "/");
		assert(a[10] == "-76");
		assert(a[11] == "..");
		assert(a[12] == "3");
		return 0;
	}

	unittest
	{
		string[] a = lex.split("a:=(2,3,4,5)$1..200");
		assert(a.length == 15);
		assert(a[0] == "a");
		assert(a[1] == ":=");
		assert(a[2] == "(");
		assert(a[3] == "2");
		assert(a[4] == ",");
		assert(a[5] == "3");
		assert(a[6] == ",");
		assert(a[7] == "4");
		assert(a[8] == ",");
		assert(a[9] == "5");
		assert(a[10] == ")");
		assert(a[11] == "$");
		assert(a[12] == "1");
		assert(a[13] == "..");
		assert(a[14] == "200");
		assert(a[15] == ")");
		return 0;
	}
}


