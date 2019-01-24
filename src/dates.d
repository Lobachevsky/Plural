module dates;

import std.conv;

string dateLocale = "iso";

public class Day {
    public int yyyymmdd;

    public this(int arg) {
        this.yyyymmdd = arg;
        // assert (arg == daterep(dno(this.day)));
    }

	public this(string arg) {
        // iso dates
		int e = (arg[0] - 48) * 10000000; // yyyy
		e += (arg[1] - 48) * 1000000;
		e += (arg[2] - 48) * 100000;
		e += (arg[3] - 48) * 10000;

		e += (arg[5] - 48) * 1000; // mm
		e += (arg[6] - 48) * 100;

		e += (arg[8] - 48) * 10; // dd
		e += arg[9] - 48;

		this.yyyymmdd = e;
	}

    public this(int yyyy, int mm, int dd) {
        int t = yyyy * 10000 + mm * 100 + dd;
        this.yyyymmdd = t;
        // assert (t == daterep(dno(this.day)));
    }

    public int dayOfWeek() {
        return (dno(this.yyyymmdd) - 2) % 7;
    }

    public void addDays(int arg) {
        this.yyyymmdd = daterep(dno(this.day) + arg);
    }

    public void addMonths(int arg) {
        int t = this.day;
        int u = t / 100;
        int v = u % 100;
        int w = u / 100;
        int x = w * 12 + v + arg - 1;
        int y = 100 * (x / 12) + x % 12 + 1;
        int z = y * 100 + t % 100;
        this.yyyymmdd = z;
        if (z == daterep(dno(this.day))) return; // 2001-01-31
        this.yyyymmdd = --z;
        if (z == daterep(dno(this.day))) return; // 2001-04-30
        this.yyyymmdd = --z;
        if (z == daterep(dno(this.day))) return; // 2004-02-29
        this.yyyymmdd = --z;
        if (z == daterep(dno(this.day))) return; // 2001-02-28
        // assert false;
    }

    public void addYears(int arg) {
        int t = this.yyyymmdd;
        int z = t + arg * 10000;
        this.yyyymmdd = z;
        if (z == daterep(dno(this.day))) return; // 2001-01-31
        this.yyyymmdd = --z;
        if (z == daterep(dno(this.day))) return; // 2001-02-28
        // assert false;
    }

	public override string toString() {
			string s = to!string(this.yyyymmdd);
			return s[0 .. 4] ~ "-" ~ s[4 .. 6] ~ "-" ~ s[6 .. 8];
		}

    public string toString(string arg) {
        switch (arg) {
			case "e":
				return this.toStringEur();
			case "u":
				return this.toStringUsa();
			default:
				return this.toString();
        }
    }

    private string toStringEur() {
        string s = to!string(this.yyyymmdd);
        return s[6 .. 8] ~ "." ~ s[4 .. 6] ~ "." ~ s[0 .. 4];
    }

    private string toStringUsa() {
        string s = to!string(this.yyyymmdd);
        return s[4 .. 6] ~ "/" ~ s[6 .. 8] ~ "/" ~ s[0 .. 4];
    }

    private static int daterep(int x) {
        int z = 100 * (x + 693900);
        int c = (z - 25) / 3652425;
        int t = 100 * ((z - c * 3652425 - 25) / 100);
        int y = (t + 75) / 36525;
        int d = 100 * ((175 + t - 36525 * y) / 100);
        int m = (d - 60) / 3060;
        int r1 = (50 + d - m * 3060) / 100;
        int r2 = 100 * (1 + (m + 2) % 12);
        int r3 = 10000 * (c * 100 + y);
        if (m >= 10) r3 = r3 + 10000;
        return r1 + r2 + r3;
    }

    private static int dno(int x) {
        int m = x % 10000 / 100;
        int d = x % 100;
        int y = x / 10000;
        if (m <= 2) y = y - 1;
        int t = (40 + d * 100 + 3060 * ((m + 9) % 12)) / 100;
        int y1 = y / 100 * 3652425 / 100;
        int y2 = y % 100 * 36525 / 100;
        return y1 + y2 + t - 693900;
    }

    public int year() {
        return this.yyyymmdd / 10000;
    }

    public int month() {
        return this.yyyymmdd % 10000 / 100;
    }

    public int day() {
        return this.yyyymmdd % 100;
    }

    public int value() {
        return this.yyyymmdd;
    }

	public static int week(int year, int wk) {
		int[] wb = [0, -1, -2, -3, 3, 2, 1];
		Day d = new Day(101 + year * 10000);
		int t = d.dayOfWeek();
		d.addDays(wb[t]);
		d.addDays(7 * (wk - 1));
		return d.day;
	}

	public static int roundtrip(int d) {
		return daterep(dno(d));
	}

	public static bool isValid(int d) {
		return d == roundtrip(d);
	}
}