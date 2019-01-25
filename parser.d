module parser;
import data;
import lexical;
import std.string;
import std.conv;
import functions;
import arith;
import index;
import rotate;
import slash;
import encdec;
import catfat;
import xpose;
import dates;

// $(DMDInstallDir)dmd2\windows\lib64\phobos64.lib

Onion[string] globals;
int parsermode;

string token;
string[] line;
int tptr;

public class pratt {

	// static string token;
	// static string line[];
	// static int tptr;

	private static Onion led(string arg, Onion left) {
		int bp = dbp(arg);
	    switch (arg) {

			case ":=": return fns.assign(left, expr(bp));
	    
	    	// arithmetic functions
    		case "*": return fns.dyad0(left, expr(bp), function(double x,y) {return x * y;});
    		case "%": return fns.dyad0(left, expr(bp), function(double x,y) {return x / y;});
    		case "+": 
				if (token == "[") {
					advance("[");
					Onion axis = expr(0);
					advance("]");
				} 
				return fns.dyad0(left, expr(bp), function(double x,y) {return x + y;}); 
				
    		case "-": return fns.dyad0(left, expr(bp), function(double x,y) {return x - y;});

			/*
    		case "mod": return Onion.mod(left, expr(bp));
    		case "min": return Onion.min(left, expr(bp));
    		case "max":	return Onion.max(left, expr(bp));
    		case "round": return Onion.round(left, expr(bp));
    		case "log": return Onion.log(left, expr(bp));
    		case "power": return Onion.power(left, expr(bp));
    		case "nroot": return Onion.nroot(left, expr(bp));
				*/
    		
    		// logical functions
    		case "<": return fns.dyad0(left, expr(bp), function(double x,y) {return Arith.lt(x, y);});
    		case "<=": return fns.dyad0(left, expr(bp), function(double x,y) {return Arith.le(x, y);});
    		case ">=": return fns.dyad0(left, expr(bp), function(double x,y) {return Arith.ge(x, y);});			
    		case ">": return fns.dyad0(left, expr(bp), function(double x,y) {return Arith.gt(x, y);});
    		case "=": return fns.dyad0(left, expr(bp), function(double x,y) {return Arith.eq(x, y);});
    		case "<>": return fns.dyad0(left, expr(bp), function(double x,y) {return Arith.ne(x, y);});

    		case "&": return fns.dyad0(left, expr(bp), function(double x,y) {return Arith.and(x, y);});
    		case "|": return fns.dyad0(left, expr(bp), function(double x,y) {return Arith.or(x, y);});
    		// case "xor": return Onion.ne(left, expr(bp)); // xor is the same as ne
    		
    		case "[":
				// Onion a = expr(bp);
				Onion[] args = new Onion[42];
				int c = 0;
				// advance("]");
				if (token != "]") {
					while (true) {
						args[c++] = expr(0);
						if (token != ",") break;
						advance(",");
					}
				}
				advance("]");

				if (token != ":=") {
					if (c == 1) return index.idx(left, args[0]);
					Onion r;
					r.t = 42;
					r.na = args[0 .. c];
					return index.idx(left, r);
				}

				// if (token != ":=") {
				// 	return fns.idx(left, a);
				// } else {
				advance(":=");
				Onion b = expr(0);
				if (c == 1) {
					return index.idxasgn(left, args[0], b);
				} else {
					Onion r;
					r.t = 42;
					r.na = args[0 .. c];
					return index.idxasgn(left, r, b);
				}
				// }

			case "*$": return fns.reshape(left, expr(bp));
			case "..": return fns.diota(left, expr(bp));
			case "@\\": return xpose.dtranspose(left, expr(bp));
			case "@|": return rotate.drotate(left, expr(bp));
		    case "/": return slash.compress(left, expr(bp));
			case "\\": return slash.expand(left, expr(bp));
			case "<:": return encdec.decode(left, expr(bp));
			case ">:": return encdec.encode(left, expr(bp));
			case "+&": return catfat.cat(left, expr(bp));
			// case "-&": return catfat.ravel(left, expr(bp));
			case "*&": return catfat.lam(left, expr(bp));

				/*
    		
    		case "(":
    			Onion[] args = new Onion[42];
    			int c = 0;
    			String fn = left.str;
    			if (!token.equals(")")) {
    				while (true) {
    					args[c++] = expr(0);
    					if (!token.equals(",")) break;
    					advance(",");
    				}
    			}
    			advance(")");
    			
    			// functional notation handled here
    			switch(fn) {
    				case "power": return Onion.power(args[0], args[1]);
    				default: return Onion.foo(args[0], args[1]);
    			}
    							
    		// case ":=": return left.assign(expr(bp));

*/

    		default: 
				throw new Exception("Parser error in led");
				Onion r;
				r.t = 0;
    			return r;
	    }	    
	}

	private static Onion nud(string arg) {

		Onion result;
		int bp = mbp(arg);
		switch (arg) {
			/*
		case "+": return expr(bp);
		case "-": return Onion.negate(expr(bp));
		case "not": return Onion.not(expr(bp)); 
		case "abs": return Onion.abs(expr(bp)); 
		case "trunc": return Onion.trunc(expr(bp));
		case "exp": return Onion.exp(expr(bp));
		case "ln": return Onion.ln(expr(bp));
			*/
		
		case "(":
			// result = expr(0);
			// advance(")");
			// return result;
			Onion[] args = new Onion[42];
			int c = 0;
			// String fn = left.str;
			if (token != ")") {
				while (true) {
					args[c++] = expr(0);
					if (token != ",") break;
					advance(",");
				}
			}
			advance(")");
			if (c == 1) return args[0];
			Onion r;
			r.t = 42;
			r.na = args[0 .. c];
			return r;
		case ")":
			return resolve1(arg);
			/*
		case "\n":
			assert (1 == 42);
			*/
		case "@|": return rotate.mreverse(expr(bp));
		case "^": return fns.first(expr(bp));
		case "*$": return fns.shape(expr(bp));
		case "-&": return catfat.ravel(expr(bp));

		case "configuration":
		case "currency":
		case "deposits":
		case "curve":
		case "interpolation":
		case "interpolationValue":
		case "cbswaps":
		case "swaps":
		case "turns":
		case "serialFutures":
		case "immFutures":
		case "fras":
		case "basisSwaps":
			throw new Exception("not implemented yet");

		default:
			return resolve2(arg);
		}
	}


	private static int mbp(string arg) {
		return (parsermode == 1) ? mbp1(arg) : mbp2(arg);
	}

	private static int mbp1(string arg) {

		// left to right monadic order of precedence

		switch(arg) {
			case "+": 
			case "-": 
			case "not": 
			case "abs": 
			case "trunc":
			case "exp": 
			case "ln": 
				return 4;

			case "configuration":
			case "currency":
			case "deposits":
			case "curve":
			case "interpolation":
			case "interpolationValue":
			case "cbswaps":
			case "swaps":
			case "turns":
			case "serialFutures":
			case "immFutures":
			case "fras":
			case "basisSwaps":
				return 4;

			default: return 0;
		}
	}

	private static int mbp2(string arg) {

		// iversonian (right to left) order of precedence

		switch(arg) {
			case "+": 
			case "-": 
			case "not": 
			case "abs": 
			case "trunc": 
			case "exp": 
			case "ln": 
				return tptr;

			case "configuration":
			case "currency":
			case "deposits":
			case "curve":
			case "interpolation":
			case "interpolationValue":
			case "cbswaps":
			case "swaps":
			case "turns":
			case "serialFutures":
			case "immFutures":
			case "fras":
			case "basisSwaps":
				return tptr;

			default: return 0;
		}
	}

	private static int dbp(string arg) {
		return (parsermode == 1) ? dbp1(arg) : dbp2(arg);
	}

	private static int dbp1(string arg) {

		// standard precedence (left-to-right) order of presidents

		switch (arg) {
		case ")":
		case "]":
			return 0;

		/* default: return tptr; forget about it */

		case "round":
		case "abs":
		case "trunc":
		case "exp":
		case "ln":
		case "log":
		case "power":
		case "nroot":
		case "mod":
		case "min":
		case "max":
			return 2;
		case "*":
		case "%":
			return 6;
		case "+":
		case "-":
			return 5;
		case "<":
		case "<=":
		case ">=":
		case ">":
			return 7;
		case "=":
		case "<>":
			return 9;
		case "&":
			return 10;
		case "|":
		case "xor":
			return 11;
		case ":=":
			return 13;
		case "(":
		case "[":
			return 15;
		case "*$":
		case "..":
		case "@\\":
		case "@|":
		case "/":
		case "\\":
		case "<:":
		case ">:":
		case "+&":
		case "-&":
		case "*&":
			return 16;
		default:
			return 0; 
		}
	}

	private static int dbp2(string arg) {

		// iversonian ordure of presidents

		switch (arg) {
			case ")":
			case "]":
				return 0;

			case "round":
			case "abs":
			case "trunc":
			case "exp":
			case "ln":
			case "log":
			case "power":
			case "nroot":
			case "mod":
			case "min":
			case "max":
				return tptr; // 2;
			case "*":
			case "%":
				return tptr; // 6;
			case "+":
			case "-":
				return tptr; // 5;
			case "<":
			case "<=":
			case ">=":
			case ">":
				return tptr; // 7;
			case "=":
			case "<>":
				return tptr; // 9;
			case "&":
				return tptr; // 10;
			case "|":
			case "xor":
				return tptr; // 11;
			case ":=":
				return tptr; // 13;
			case "(":
			case "[":
				return tptr; // 15;
			case "*$":
			case "..":
			case "@\\":
			case "@|":
			case "/":
			case "\\":
			case "<:":
			case ">:":
			case "+&":
			case "-&":
			case "*&":
				return tptr; // 16;
			default:
				return 0; 
		}
	}

	private static Onion expr(int rbp) {

		string t;
		Onion left;
		int l;

		t = token;
		token = getNext();
		left = nud(t);

		while (rbp < (l = dbp(token))) {
			t = token;
			token = getNext();
			left = led(t, left);
		}
		return left;
	}

	private static string getNext() {
		tptr++;
		return line[tptr - 1];
	}

	public static Onion parse(string arg, Onion[string] data) {
		globals = data;
		line = lex.split(arg);
		tptr = 0;
		token = getNext();
		return expr(0);
	}

	private static void advance(string arg) {
		if (arg != token) throw new Exception("Parser error in advance");
		token = getNext();
	}

	private static Onion resolve1(string arg) {
		int idx;
		double d;
		
		if (arg[0] == '-' || isDigit(arg[0])) {
			Onion r;
			if (-1 != indexOf(arg, " ")) r = daconv(arg); // r.t = 23;
			else r = to!double(arg); // r.t = 3;
			return r; 
		}
		
		if (isAlphabetic(arg[0] )) {
			Onion r;
			r.t = -10;
			r.st = arg;
			return r; 
		}

		Onion r;
		r.t = 0;
		return r;
	}
	private static Onion resolve2(string arg) {
		int idx;
		double d;
		char sep = 7;

		if (arg.length > 7 && isDigit(arg[0]) && arg[4] == '.' && arg[7] == '.') {
			Onion r;
			if (-1 != indexOf(arg, sep)) {
				r = dtconv(arg);
				r.s = new int[1];
				r.s[0] = cast(int)r.da.length;
			} else {
				r = new Day(arg);
			}
			return r;
		}

		if (arg[0] == '-' || isDigit(arg[0])) {                // numeric literal
			Onion r;
			if (-1 != indexOf(arg, sep)) {                     // vector literal
				//r.t = 23;
				//r.r = 0;
				r = daconv(arg);
				r.s = new int[1];
				r.s[0] = cast(int)r.da.length;
			} else {
				// r.t = 3;
				// r.r = 0;
				r = to!double(arg);
			}
			return r; 
		}

		if (arg[0] == '"') {                 // string literal
			Onion r;
			if (-1 != indexOf(arg, sep)) {   // vector literal
				//r.t = 23;
				//r.r = 0;
				r = dsconv(arg);
				r.s = new int[1];
				r.s[0] = cast(int)r.da.length;
			} else {
				// r.t = 3;
				// r.r = 0;
				r = arg[1 .. $-1];
			}
			return r; 
		}

		if (isAlphabetic(arg[0])) {
			if(arg in globals) {
				Onion r = globals[arg];
				r.st = arg;
				return r; 
			} else {
				Onion r;
				r.t = -10;
				r.st = arg;
				return r;
			}
		}

		// d = Double.parseDouble(arg);
		// if (!Double.isNaN(d)) {
		// 	return new Onion(d);
		// }

		Onion r;
		r.t = 0;
		return r;
	}
	static bool isDigit(char arg) {
		return arg > 47 && arg < 58;
	}
	static bool isAlphabetic(char arg) {
		return (arg == '_') || (arg > 64 && arg < 91) || (arg > 96 && arg < 123);
	}
	static double[] daconv(string arg) {
		char sep = 7;
		string[] t = split(arg, sep);
		// double[] r = new double[t.length];
		// for (int i = 0; i < t.length; i++) r[i] = to!double(t[i]);
		return to!(double[])(t);
		// return r;
	}

	static string[] dsconv(string arg) {
		char sep = 7;
		string[] t = split(arg, sep);
		string[] r = new string[t.length];
		for (int i = 0; i < t.length; i++) r[i] = t[i][1 .. $-1];
		return r;
	}

	static Day[] dtconv(string arg) {
		char sep = 7;
		string[] t = split(arg, sep);
		Day[] r = new Day[t.length];
		for (int i = 0; i < t.length; i++) r[i] = new Day(t[i]);
		return r;
	}
}
