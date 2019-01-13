module stats;
import std.math;
import std.conv;
    
    public class StatFilters
    {
        public string warning_message_str = "";       
        public string error_message_str   = "";
		// public double nan = std.math.NaN(0);
        void PentadiagSolve(double[] d, double[] e, double[] f, double[] g, double[] h, double[] b, double [] x, int n, bool bk_sym)
        {
	        double[] alpha, delta, gamma, beta, c, z;
	        int k;

	        ///////////////////////////////////////////////////////////////////////////////
	        // Solve a pentadiagonal linear system Ax=b where A is a strongly nonsingular 
	        // matrix:
	        //    
	        //
	        //         /  d0  e0  f0   0   0    ...     0    \   / x0   \    /  b0  \
            //         |  g0  d1  e1  f1   0    ...     0    |   | x1   |    |  b1  |
            //         |  h0  g1  d2  e2   0    ...     0    | x | x2   | =  |  b2  |
            //         |   :   :   :   :   :     :     fn-3  |   | x4   |    |  b3  |
            //         |   0   0   0   0  gn-3  dn-2   en-2  |   | :    |    |   :  |
            //         \   0   0   0   0  hn-3  gn-2   dn-1  /   \ xn-1 /    \ bn-1 /
	        //
	        //
	        //
	        // Reference: G. Engeln-Muellges, F. Uhlig, "Numerical Algorithms with C"
	        // Chapter 4. Springer-Verlag Berlin (1996)
	        ///////////////////////////////////////////////////////////////////////////////
	        if (bk_sym)  //Symmetric Matrix Scheme
	        {
		        alpha=new double [n]; gamma=new double [n-1];
		        delta=new double [n-2];
		        c=new double [n]; z=new double [n];

	            // Factor A=LDL'
		        alpha[0]=d[0];
		        gamma[0]=e[0]/alpha[0];
		        delta[0]=f[0]/alpha[0];
		        alpha[1]=d[1]-e[0]*gamma[0];
		        gamma[1]=(e[1]-f[0]*gamma[0])/alpha[1];
		        delta[1]=f[1]/alpha[1];
		        for(k=2; k < n-2; k++)
		        {
			        alpha[k]=d[k]-f[k-2]*delta[k-2]-alpha[k-1]*gamma[k-1]*gamma[k-1];
                    gamma[k]=(e[k]-f[k-1]*gamma[k-1])/alpha[k]; 
			        delta[k]=f[k]/alpha[k];
		        }
		        alpha[n-2]=d[n-2]-f[n-4]*delta[n-4]-alpha[n-3]*gamma[n-3]*gamma[n-3];
		        gamma[n-2]=(e[n-2]-f[n-3]*gamma[n-3])/alpha[n-2];
		        alpha[n-1]=d[n-1]-f[n-3]*delta[n-3]-alpha[n-2]*gamma[n-2]*gamma[n-2];

	            // Update Lx=b, Dc=z 
		        z[0]=b[0];
		        z[1]=b[1]-gamma[0]*z[0];
		        for( k=2; k < n; k++)
			        z[k]=b[k]-gamma[k-1]*z[k-1]-delta[k-2]*z[k-2];
		        for ( k = 0; k < n; k++)
					c[k]=z[k]/alpha[k];

	            // Backward substitution L'x=c
		        x[n-1]=c[n-1];
		        x[n-2]=c[n-2]-gamma[n-2]*x[n-1];
		        for(k=n-3; k >=0; k--)
			        x[k]=c[k]-gamma[k]*x[k+1]-delta[k]*x[k+2];
	        }    
	        else  // Non-symmetric Matrix Scheme
	        {    
		        alpha = new double [n];   gamma = new double [n-1];
		        delta = new double [n-2]; beta  = new double [n];
		        c     = new double [n];   z     = new double [n];

		        // Factor A=LR
		        alpha[0]=d[0];
		        gamma[0]=e[0]/alpha[0];
		        delta[0]=f[0]/alpha[0];
		        beta[1]=g[0];
		        alpha[1]=d[1]-beta[1]*gamma[0];
		        gamma[1]=( e[1]-beta[1]*delta[0] )/alpha[1];
		        delta[1]=f[1]/alpha[1];

		        for( k=2; k < n-2; k++)
		        {
			        beta[k]=g[k-1] - h[k-2]*gamma[k-2];
			        alpha[k]=d[k]-h[k-2]*delta[k-2]-beta[k]*gamma[k-1];
			        gamma[k]=( e[k]-beta[k]*delta[k-1] )/alpha[k];
			        delta[k]=f[k]/alpha[k];
		        }

		        beta[n-2]=g[n-3]-h[n-4]*gamma[n-4];
		        alpha[n-2]=d[n-2]-h[n-4]*delta[n-4]-beta[n-2]*gamma[n-3];
		        gamma[n-2]=( e[n-2]-beta[n-2]*delta[n-3] )/alpha[n-2];
		        beta[n-1]=g[n-2]-h[n-3]*gamma[n-3];
		        alpha[n-1]=d[n-1]-h[n-3]*delta[n-3]-beta[n-1]*gamma[n-2];

		        // Update Lc = b
		        c[0]=b[0]/alpha[0];
		        c[1]=(b[1]-beta[1]*c[0])/alpha[1];
		        for( k=2; k < n; k++)
			        c[k]=( b[k]-h[k-2]*c[k-2]-beta[k]*c[k-1] )/alpha[k];

		        // Backward substitution Rx=c
		        x[n-1]=c[n-1];
		        x[n-2]=c[n-2]-gamma[n-2]*x[n-1];
		        for( k=n-3; k >=0; k--)
			        x[k]=c[k]-gamma[k]*x[k+1]-delta[k]*x[k+2];    

	        }
        }
        public double[] HPflt(double[] y, double lambda)
        {
            double [] d, e, f;
	        int  n;
            bool cNaN = false;

            //y is the array being smoothed
            //x is the smoothed array
            //lambda must be a positive parameter
            warning_message_str = "";
            error_message_str   = "";
            n = y.length;          // number of elements in the array
            for (int i = 0; i < n &&!cNaN; i++)
            {
                if (std.math.isNaN(y[i]))
                {
                    warning_message_str = "missing values in the input series.";
                    cNaN = true;
                }
            }
            double[] x = new double[n];
            d = new double[n];      // diagonal 
            e = new double[n - 1];  // superdiagonal
            f = new double[n - 2];  // elements directly above superdiagonal
            d[0] = lambda + 1;
            d[1] = 5 * lambda + 1;
            d[n - 2] = d[1]; d[n - 1] = d[0];
            e[0] = -2 * lambda; e[1] = -4 * lambda;
            f[0] = lambda; f[1] = lambda;
            for (int k = 2; k < n - 2; k++)
            {
                d[k] = 6 * lambda + 1;
                e[k] = -4 * lambda;
                f[k] = lambda;
            }
            e[n - 2] = e[0];
            //g = e; h = f; 
            //symmetric matrix
            //g = new double [n-1];  // not necesssary to allocate memory for g, h
            //h = new double [n-2];  // if the matrix is symmetric g = e; h = f; 	
            //for(k = 0; k < n-2; k++)
            //{
            //	g[k] = e[k];
            //	h[k] = f[k];
            //}
            //g[n-2] = e[n-2];

            //
            // /  d0  e0  f0   0   0    ...     0    \   / x0   \    /  b0  \
            // |  e0  d1  e1  f1   0    ...     0    |   | x1   |    |  b1  |
            // |  f0  e1  d2  e2   0    ...     0    | x | x2   | =  |  b2  |
            // |   :   :   :   :   :     :     fn-3  |   | x4   |    |  b3  |
            // |   0   0   0   0  en-3  dn-2   en-2  |   | :    |    |   :  |
            // \   0   0   0   0  fn-3  en-2   dn-1  /   \ xn-1 /    \ bn-1 /
            //
            PentadiagSolve(d, e, f, e, f, y, x, n, true);
            if (lambda <= 0)
            {
                warning_message_str = "lambda = " ~ to!string(lambda) ~ ". lambda has a negative value.";
            }
            return x;
        }
        public double [] bkflt(double[] y, int K, int[] list...)
        {
			//  This function is modified from the Matlab version
			//  Baxter & King Band-Pass Filter where:
			//  y  - the original series that has to be filtered
			//  K  - number of terms in approximating moving average
			//  list is optional parameters
			//  up   = list[0], period corresponding to highest frequency, default is 6.
			//  dn   = list[1], period corresponding to lowest frequency, default is 32.
			//  flag = list[2],  default is false. 
			//  if it is false, it means without demeaning, true.  with demeaning
			//  x - the band-pass filtered series
			//
			//  Ref: 'Measuring Business Cycles: Approximate Band-Pass Filters
			//        for Microeconomic Time Series' by Marianne Baxter and Robert G. King

            double phi;
	        int T, i, k, up = 6, dn = 32;
            bool flag = false;

            warning_message_str = "";
            error_message_str = "";

            int nl = list.length;
            if (nl == 1)
            {
                up = list[0];
            }
            else if (nl == 2)
            {
                up = list[0];
                dn = list[1];
            }
            else if (nl == 3)
            {
                up = list[0];
                dn = list[1];
                flag = cast(bool)list[2];
            }
	        if (up > dn)
	        {
                warning_message_str = " Periods reversed: switching higher periodicity and lower periodicity.";
		        int tmp = dn;
		        dn = up; 
				up = tmp;
	        }
	        if (up < 2)
	        {
		        up = 2;
		        warning_message_str = " Higher periodicity > max: setting it = 2; ";
	        } 
	        T = y.length;
            double[] x = new double[T];
            if (K >= T / 2)
            {
                for (i = 0; i < T; i++)
                    x[i] = std.math.NaN(0);
                error_message_str = "K = " ~ to!string(K) ~ "; K should be less than a half of size of input series y.";
            }
            else
            {
                // Implied Frequencies
                double uw = 2 * std.math.PI / up;
                double lw = 2 * std.math.PI / dn;
                // Construct filter weights for bandpass filter (a[0]....a[K]). 
                double[] akvec = new double[K + 1];
                akvec[0] = (uw - lw) / std.math.PI;  //weight at k = 0 
                for (k = 1; k < K + 1; k++)
                    akvec[k] = (std.math.sin(k * uw) - std.math.sin(k * lw)) / (k * std.math.PI); // weights at k=1,2,...K 
                // Impose constraint on frequency response at w = 0 
                // (If high pass filter, this amounts to requiring that weights sum to zero).
                // (If low pass filter,  this amounts to requiring that weights sum to one).
                if (dn > 1000)
                {
                    warning_message_str ~= " dn > 1000: assuming low pass filter.";
                    phi = 1;
                }
                else
                    phi = 0;
                // sum of weights without constraint
                double theta = akvec[0];
                for (k = 1; k < K + 1; k++)
                    theta += akvec[k];
                theta *= 2;
                theta -= akvec[0];

                // amount to add to each nonzero lag/lead to get sum = phi
                theta = phi - (theta / (2 * K + 1));
                // adjustment of weights
                for (k = 0; k < K + 1; k++)
                    akvec[k] += theta;

                // filter the time series
                // Set vector of weights
                double[] avec = new double[2 * K + 1];
                avec[K] = akvec[0];
                for (k = 1; k < K + 1; k++)
                {
                    avec[K - k] = akvec[k];
                    avec[K + k] = akvec[k];
                }
                double mtmp = 0.0;
                for (k = K; k < T - K; k++)
                {
                    x[k] = 0.0;
                    for (i = 0; i < 2 * K + 1; i++)
                        x[k] += avec[i] * y[k - K + i];
                    mtmp += x[k];
                } 
                mtmp /= (T - 2 * K);
                if (flag)  //demeaned
                {
                    for (k = K; k < T - K; k++)
                        x[k] -= mtmp;
                }
            }
            return x;
        } //close of function bkflt
    } // close class StatFilters

    public class Statfuncs
    {
        public string warning_message_str = "";
        public string error_message_str = "";
        public double[] Dlog(double[] x, int[] n...)
        {
            int nel = 0, nn;
            double[] y;
            warning_message_str = ""; error_message_str = "";
            nel = x.length;
            y = new double[nel];

            if (n.length == 1)
                nn = n[0];
            else
                nn = 1;
            for (int i = 0; i < nn; i++)
                y[i] = std.math.NaN(0);
            for(int i = nn; i < nel; i++)
                y[i] = std.math.log(x[i]/x[i-nn]);
            return y;

        }
        public double[] Dlogya(double[] x, int[] n...)
        {
            int nel = 0, nn;
            double[] y;
            warning_message_str = ""; 
			error_message_str = "";
            nel = x.length;
            y = new double[nel];

            if (n.length == 1)
                nn = n[0];
            else
                nn = 1;
            for (int i = 0; i < nn; i++)
                y[i] = std.math.NaN(0);
            for (int i = nn; i < nel; i++)
                y[i] = std.math.log(x[i] / x[i - nn]);
            return y;

        }
        public double[] sar(double[] x, int n)
        {
            int nel;
            double[] y;

	        warning_message_str = ""; error_message_str = "";
            nel = x.length;  // number of elements in the array
            y = new double [nel];

	        for(int i = 0; i < 1; i++)
		        y[i] = std.math.NaN(0);
	        for(int i = n; i < nel; i++)
	        {
		        y[i] = (x[i]/x[i-1] - 1)*n*100.0;
	        }
            return y;
        }
        public double[] sar(double[] x, int n, int freq)
        {
            int nel;
            double[] y;

            warning_message_str = ""; error_message_str = "";
            nel = x.length;  // number of elements in the array
            y = new double[nel];
            if (n > 0 && n < nel)
            {
                for (int i = 0; i < n; i++)
                    y[i] = std.math.NaN(0);
                for (int i = n; i < nel; i++)
                {
                    y[i] = (x[i] / x[i - n] - 1) * (freq * 100.0) / n;
                }
            }
            else
                error_message_str = "The value of n = " ~ to!string(n) ~ ", It must be between 1 and " ~ to!string(nel);

            return y;
        }

        public double STL_medianTry(double[] x)
        {

            int lelements, nel = 0;

            // return the median of the values in array x
            error_message_str = ""; warning_message_str = "";
            lelements = x.length; // number of elements in the array
            x = x.sort; // Array.Sort(x, 0, lelements);
            if ((lelements % 2) != 0)     // if number of elements is odd
                return x[(lelements) / 2];
            else                     // if number of elements is even
                return (x[(lelements) / 2] + x[(lelements) / 2 - 1]) / 2;
        }
        public double STL_median(double[] x)
        {

			// return STL_medianTry(x);

	        double [] ptemp;
	        int lelements, nel = 0;

            // return the median of the values in array x
	        error_message_str = ""; warning_message_str = "";
            lelements = x.length; // number of elements in the array
	        ptemp = new double [lelements];
	        for (int i = 0; i < lelements; i++)
		        if(!std.math.isNaN(x[i])) 
		        {
			        ptemp[i] = x[i]; 
			        nel ++;
		        }    
	        if(nel < lelements)
	            warning_message_str ~= "missing values in series. They will be eliminated from series to compute median. ";
            // Sort the values between ptemp and ptemp+nel-1

	        ptemp = ptemp.sort; // Array.Sort(ptemp, 0, nel);
            //if ((nel % 2) != 0)     // if number of elements is odd
            //    return ptemp[(nel - 1) / 2];
            //else                     // if number of elements is even
            //    return (ptemp[(nel) / 2] + ptemp[(nel) / 2 - 1]) / 2;
            if ((lelements % 2) != 0)     // if number of elements is odd
                return ptemp[(lelements - 1) / 2];
            else                     // if number of elements is even
                return (ptemp[-1+(lelements / 2)] + ptemp[-1 + (lelements / 2 + 1)]) / 2;
        }
        public double STL_mean(double[] x)
        {
	        double tmp  = 0.0;
	        int lelements, nel  = 0;
            // return the mean of the values in array x  

	        warning_message_str = ""; error_message_str = "";
            lelements = x.length;    // number of elements in the array
	        if( lelements  > 0)
	        {
		        for(int i = 0; i < lelements; i++)
		        {
			        if(!std.math.isNaN(x[i]))
			        {
				        tmp += x[i];
				        nel ++;
			        }
		        }
                tmp /= nel;
	        }
	        if(nel < lelements)
    	        warning_message_str ~= "missing values in series. They will be eliminated from series to compute mean. ";
            return tmp;
        }
        public double STL_min(double[] x)
        {
            double [] ptemp;
	        int lelements, nel = 0;
	        // double tmp;
            // return the min value in array x  
	        error_message_str = ""; 
			warning_message_str = "";
            lelements = x.length; // number of elements in the array
	        ptemp = new double [lelements];
	        for (int i = 0; i < lelements; i++)
		        if(!std.math.isNaN(x[i])) 
		        {
			        ptemp[i] = x[i]; 
			        nel ++;
		        }
	        if(nel < lelements)
	            warning_message_str ~= "missing values in series. They will be eliminated from series to compute min. ";
	        // Sort the values between ptemp and ptemp + nel -1
	        ptemp = ptemp.sort; // Array.Sort(ptemp, 0, nel);
            return ptemp[0];
        }
        public double STL_max(double[] x)
        {
            double[] ptemp;
            int lelements, nel = 0;
            // double tmp;
            // return the min value in array x  
            error_message_str = ""; 
			warning_message_str = "";
            lelements = x.length; // number of elements in the array
            ptemp = new double[lelements];
            for (int i = 0; i < lelements; i++)
                if (!std.math.isNaN(x[i]))
                {
                    ptemp[i] = x[i];
                    nel++;
                }
            if (nel < lelements)
                warning_message_str ~= "missing values in series. They will be eliminated from series to compute min. ";
            // Sort the values between ptemp and ptemp + nel -1
            ptemp = ptemp.sort; // Array.Sort(ptemp, 0, nel);
            return ptemp[nel-1];
        }
        public double STL_gmean(double[] x)
        {

            double tmp  = 1.0;
	        int lelements, nel  = 0;
            // return the geometric mean of the values in array x  
	        // ignoring missing values and negative values
	        warning_message_str = ""; error_message_str = "";
	        // checking if it is an array of doubles
            lelements = x.length; // number of elements in the array
	        if( lelements  > 0)
	        {
		        for(int i = 0; i < lelements; i++)
		        {
			        if((!std.math.isNaN(x[i])) && (x[i] >= 0.0))
			        {
				        tmp *= x[i];
				        nel ++;
			        }
		        }
		        if((tmp > 0.0)&&(nel > 0))
			        tmp = std.math.pow(tmp,1.0/nel);
                else
                    tmp = std.math.NaN(0);

	        }
            if (nel < lelements)
            {
                warning_message_str ~= "Either missing values or zeros or negative values in series. They will be eliminated from series to compute geometric mean. ";
                //tmp = double.NaN;
            }
            return tmp;
        }
        public double STL_hmean(double[] x)
        {
	        double tmp  = 0.0;
	        int lelements, nel  = 0;
            // return the harmonic mean of array *x  
	        warning_message_str = ""; error_message_str = "";
            lelements = x.length; // number of elements in the array
	        if( lelements  > 0)
	        {
		        for(int i = 0; i < lelements; i++)
		        {
			        if((!std.math.isNaN(x[i])) && (x[i] != 0.0))
			        {
				        tmp += (1.0/x[i]);
				        nel ++;
			        }
		        }
                if ((tmp > 0.0) && (nel > 0))
                    tmp = nel/tmp;
                else
                    tmp = std.math.NaN(0);

	        }
	        if(nel < lelements)
	            warning_message_str ~= "Either missing values or zeros or negative values in series. They will be eliminated from series to compute harmonic mean. ";

	        return tmp;
        }
        public double STL_std(double[] x, bool[] unbiased...)
        {
            double tmp  = 0.0, tmp2 = 0.0;
	        int lelements, nel  = 0;
            // return the standard deviation of the values in array x  
	        warning_message_str = ""; error_message_str = "";
            lelements = x.length; // number of elements in the array
	        if( lelements  > 0)
	        {
		        for(int i = 0; i < lelements; i++)
		        {
			        if(!std.math.isNaN(x[i]))
			        {
				        tmp  += x[i];
				        tmp2 += x[i]*x[i];
				        nel ++;
			        }
		        }
		        tmp2 -= tmp*(tmp/nel);
                if (unbiased.length == 1)
                {
                    if (!unbiased[0]) //biased 
                        tmp2 = std.math.sqrt(tmp2 / (nel));
                    else        //unbiased
                        tmp2 = std.math.sqrt(tmp2 / (nel - 1));
                }
                else
                {  //default is unbiased
                    tmp2 = std.math.sqrt(tmp2 / (nel - 1));
                }

	        }
	        if(nel < lelements)
	            warning_message_str ~= "missing values in series. They will be eliminated from series to compute standard deviation. ";
            return tmp2;
        }
        public double STL_var(double [] x, bool[] unbiased...)
        {
	        double tmp  = 0.0, tmp2 = 0.0;
	        int lelements, nel  = 0; 

            //default is unbiased
            //return the variance of the values in array x  
	        warning_message_str = ""; 
			error_message_str = "";

            lelements = x.length; //number of elements in the array
	        if( lelements  > 0)
	        {
		        for(int i = 0; i < lelements; i++)
		        {
			        if(!std.math.isNaN(x[i]))
			        {
				        tmp  += x[i];
				        tmp2 += x[i]*x[i];
				        nel ++;
			        }
		        }
		        tmp2 -= tmp*(tmp/nel);

                if (unbiased.length == 1)
                {
                    if (!unbiased[0]) //biased variance
                        tmp2 = tmp2 / (nel);
                    else         //unbiased variance
                        tmp2 = tmp2 / (nel - 1);
                }
                else
                {
                    tmp2 = tmp2 / (nel - 1);
                }
	        }
	        if(nel < lelements)
	            warning_message_str ~= "missing values in series. They will be eliminated from series to compute variance. ";
            return tmp2;
        }
        public double STL_kurtosis(double[] x, bool[] unbiased...)
        {
	        double mx  = 0.0, vx = 0.0, kx = 0.0, sx, tmp;
	        int lelements, nel  = 0;//default is unbiased
            // return the kurtosis of the values in array x  

            warning_message_str = ""; 
			error_message_str = "";

            lelements = x.length; // number of elements in the array
	        if( lelements  > 0)
	        {
		        for(int i = 0; i < lelements; i++)
		        {
			        if(!std.math.isNaN(x[i]))
			        {
				        mx  += x[i];
				        vx  += x[i]*x[i];
				        nel ++;
			        }
		        }
		        vx -= mx*(mx/nel); //biased variance x n
		        //vx /= nel; //biased variance
		        sx = vx/(nel-1); //unbiased variance
		        mx /= nel;     //mean  
		        for(int i = 0; i < lelements; i++)
		        {
			        if(!std.math.isNaN(x[i]))
			        {  
				        tmp = (x[i] - mx)*(x[i] - mx);
				        kx  += tmp*tmp;
			        }
		        }

	        }
            if (unbiased.length == 1)
            {
                if (!unbiased[0]) //biased kurtosis
                    kx = kx * nel / ((vx * vx));
                else      // unbiased kurtosis
                {
                    if (nel >= 4)
                        //Most popular defination of kurtosis
                        kx = ((nel + 1) * nel * kx / (vx * vx) - 3 * (nel - 1)) * (nel - 1) / ((nel - 2) * (nel - 3));
                    //Matlab version of kurtosis
                    //kx = ((nel+1)*nel*kx/(vx*vx) - 3*(nel-1)) * (nel-1)/((nel-2)*(nel-3)) + 3;
                    else
                        kx = std.math.NaN(0);
                }
            }
            else
            {
                if (nel >= 4)
                    //Most popular defination of kurtosis
                    kx = ((nel + 1) * nel * kx / (vx * vx) - 3 * (nel - 1)) * (nel - 1) / ((nel - 2) * (nel - 3));
				//Matlab version of kurtosis
				//kx = ((nel+1)*nel*kx/(vx*vx) - 3*(nel-1)) * (nel-1)/((nel-2)*(nel-3)) + 3;
				else
                    kx = std.math.NaN(0);
            }
	        if(nel < lelements)
	            warning_message_str ~= "missing values in series. They will be eliminated from series to compute kurtosis. ";
            return kx;
        }
        public double STL_cov(double[] x, double[] y, bool[] unbiased...)
        {
	        double mx  = 0.0;
	        double my  = 0.0, vxy = 0.0;
	        int lelements;
            // return the covariance between array x  and array y
	        warning_message_str = ""; error_message_str = "";
            lelements = x.length; // number of elements in the array

            if (lelements != y.length)
            {
		        error_message_str ~= " x and y must be of the same length! "; 
                if(lelements > y.length)
                    lelements = y.length;
            }

	        if( lelements  > 0)
	        {
		        for(int i = 0; i < lelements; i++)
		        {
					mx   += x[i];
					my   += y[i];
					vxy  += x[i]*y[i];
		        }
                mx /= lelements;
                my /= lelements;
				//               vxy -= (mx / lelements) * (my);
                if (unbiased.length == 1)
                {
                    if (unbiased[0])
                    {
                        vxy /= (lelements - 1);
                        vxy -= (mx * my * lelements / (lelements - 1));
                    }
                    else
                    {
                        vxy /= lelements;
                        vxy -= mx * my;
                    }
                }
                else  
                {   //default is unbiased
                    vxy /= (lelements - 1);
                    vxy -= (mx * my * lelements/(lelements - 1));
                }

	        }
            return vxy;
        }
        public double STL_corr(double[] x, double[] y)
        {
	        double mx  = 0.0, vx = 0.0;
	        double my  = 0.0, vy = 0.0;
	        double vxy = 0.0;
	        int lelements;
            // return the correlation between array x  and array y
	        warning_message_str = ""; error_message_str = "";
            lelements = x.length; // number of elements in the array
	        if (lelements != y.length)
            {
		        error_message_str ~= " x and y must be of the same length! "; 
                if(lelements > y.length)
                    lelements = y.length;

            }
	        if( lelements  > 0)
	        {
		        for(int i = 0; i < lelements; i++)
		        {
					mx   += x[i];
					my   += y[i];
					vx   += x[i]*x[i];
					vy   += y[i]*y[i];
					vxy  += x[i]*y[i];
		        }
		        vxy -= mx*(my/lelements);
		        vx  -= mx*(mx/lelements);
		        vy  -= my*(my/lelements);
		        vxy /= std.math.sqrt(vx*vy);

	        }
	        return vxy;
        }
        public double STL_skewness(double[] x, bool[] unbiased...)
        {
	        double mx  = 0.0, vx = 0.0, skx = 0.0, sx;
	        int lelements, nel  = 0; 

            // default is unbiased 
            // return the skewness of the values in array x  
	        warning_message_str = ""; error_message_str = "";

            lelements = x.length; // number of elements in the array
	        if( lelements  > 0)
	        {
		        for(int i = 0; i < lelements; i++)
		        {
			        if(!std.math.isNaN(x[i]))
			        {
				        mx  += x[i];
				        vx  += x[i]*x[i];
				        nel ++;
			        }
		        }
		        vx -= mx*(mx/nel);
		        vx /= (nel-1);//unbiased variance
		        sx = std.math.sqrt(vx); 
		        mx /= nel;     //mean  
		        for(int i = 0; i < lelements; i++)
		        {
			        if(!std.math.isNaN(x[i]))
			        {
				        skx  += (x[i] - mx)*(x[i] - mx)*(x[i] - mx);
			        }
		        }
                if (unbiased.length == 1)
                {
                    if (!unbiased[0])
                        skx /= ((vx * sx) * (nel - 1) * std.math.sqrt((nel - 1.0) / nel)); //biased skewness
                    else
                    {
                        skx = skx * nel / (vx * sx * (nel - 1) * (nel - 2));        //unbiased skewness
                    }
                }
                else
                {   //default case: unbiased
                    skx = skx * nel / (vx * sx * (nel - 1) * (nel - 2));        //unbiased skewness
                }

	        }
	        if(nel < lelements)
	            warning_message_str ~= "missing values in series. They will be eliminated from series to compute kurtosis. ";
	        return skx;
        }
        public double[] STL_mavg(double[] x, int n)
        {
	        double tmp  = 0.0;
	        int i, nel  = 0;
            double [] py;
            // return the mean of the values in array x  
	        warning_message_str = ""; error_message_str = "";
            nel = x.length; // number of elements in the array
            py = new double [nel];
	        if(n <= 0)
	        {
		        error_message_str ~= "n = " ~ n.to!string(n) ~ ". It is not a proper value for n. n must be a positive integer!";
		        for(i = 0; i < nel; i++)
			        py[i] = std.math.NaN(0);
	        }
	        else if( n > nel)
	        {
		        warning_message_str ~= "n = " ~ n.to!string(n) ~ ". n must be less than or equal to the length of input series!";
		        for(i = 0; i < nel; i++)
			        py[i] = std.math.NaN(0);
	        }
	        else if( nel  > 0 )
	        {
		        for(i = 0; i < n-1; i++)
		        {
			        tmp += x[i];
			        py[i] = std.math.NaN(0);
		        }
		        for( i = n-1; i < nel; i++)
		        {     
			        tmp += x[i];
			        py[i] = tmp/n;
			        tmp -= x[i-(n-1)];
		        }
	        }
	        return py;
        }
        public double[] STL_log(double [] x, string[] sb...)
        {
	        int i, nel;
            double [] py;
	        nel= x.length; // number of elements in the array
            py = new double [nel];

            if (sb.length >= 1)
            {
                if (sb[0] == "10")
                    for (i = 0; i < nel; i++)
                        py[i] = std.math.log10(x[i]);
                else if (sb[0] == "e")
                    for (i = 0; i < nel; i++)
                        py[i] = std.math.log(x[i]);
                else if (sb[0] == "2")
                    for (i = 0; i < nel; i++)
                        py[i] = std.math.log(x[i]) / std.math.log(2.0);

                else
                    for (i = 0; i < nel; i++)
                        py[i] = std.math.NaN(0);
            }
            else
            {
                for (i = 0; i < nel; i++)
                    py[i] = std.math.log(x[i]);

            }
	        return py;
        }
        public double[] STL_grwthrate(double [] x, int interval, double proportion)
        {
	        double [] y;
	        int nel  = 0;
	        warning_message_str = ""; error_message_str = "";
            nel = x.length;  // number of elements in the array
            y = new double [nel];

	        for(int i = 0; i < interval; i++)
		        y[i] = std.math.NaN(0);
	        for(int i = interval; i < nel; i++)
	        {
		        y[i] = (x[i]/x[i-interval] - 1)*proportion;
	        }
            return y;
        }


    }

    public class Datainterp  
    {   
        public string warning_message_str = "";
        public string error_message_str   = "";
        public enum EdfFreqConversionLineUpEnum { Average = 1, Center = 2, First = 3, Last = 4, Increment = 5 };
        public enum EdfFreqConversionMethEnum { Linear = 1, Geometric = 2, Spline = 3, Last = 4 };
        public enum EdfFormatEnum { Overlay = 1, Repeat = 2, Linear = 3, Spline = 4, Geometric = 5, Ovalue = 6 };
        static double[][] Mq = [[0.2933, 0.7884,-0.0817],[-0.0433, 1.2116, -0.1683],
			[-0.1683,1.2116, -0.0433],[-0.0817,0.7884, 0.2933]];
			static double[][] Mm = [[ 0.25, 0.85, -0.10 ], [ -0.15, 1.3, -0.15 ], [ -0.10, 0.85, 0.25 ]];
			void TridiagSolve(double[] a, double[] b, double[] c, double[] d, double[] x, int n)
			{
				double[] l, u, y; //define three arrays l, u, y
				int i;

				//    This function is from Fast Tridiagonal System Solver on Matlab central
				//    http://www.mathworks.com/matlabcentral/fileexchange
				//	  Solves a tridiagonal linear system   A*x = d;  
				//    x = TridiagSolve(a,b,c,d) solves a tridiagonal linear system using the very 
				//	  efficient Thomas Algorithm. The vector x is the solution.
				//
				//         /  a0  b0   0   0   0   ...   0   \   / x0   \    /  d0  \
				//         |  c0  a1  b1   0   0   ...   0   |   | x1   |    |  d1  |
				//         |   0  c1  a2  b2   0   ...   0   | x | x2   | =  |  d2  |
				//         |   :   :   :   :   :    :    :   |   | x4   |    |  d3  |
				//         |   0   0   0   0 cn-3 an-2 bn-2  |   | :    |    |   :  |
				//         \   0   0   0   0   0  cn-2  an-1 /   \ xn-1 /    \ dn-1 /
				//
				//   - The matrix A must be strictly diagonally dominant for a stable solution.
				//   - This algorithm solves this system on (5n-4) multiplications/divisions and
				//     (3n-3) subtractions.
				//   - where a is the diagonal, b is the upper diagonal, and c is 
				//     the lower diagonal of A also solves A*x = d for x. Note that a is size n 
				//     while b and c is size n-1.
				//
				//   ATTENTION : No verification is done in order to assure that A is a tridiagonal matrix.
				//   If this function is used with a non tridiagonal matrix it will produce wrong results.

				u = new double[n];
				y = new double[n];
				l = new double[n - 1];
				u[0] = a[0];
				//  1. LU decomposition ______________________________________
				// 
				//  L = / 1                \     U =  / u0  b0                \
				//      | l0 1             |          |     u1 b1             |
				//      |    l1 1          |          |        u2 b2          |
				//      |     : : :        |          |         :  :  :  bn-1 |
				//      \           ln-2 1 /          \                  un-1 /
				// 
				//	2. Forward substitution L*y=d initialization
				y[0] = d[0];
				for (i = 1; i < n; i++)
				{
					//  1. LU decomposition
					l[i - 1] = c[i - 1] / u[i - 1];
					u[i] = a[i] - l[i - 1] * b[i - 1];
					//  2. Forward substitution L*y=d
					y[i] = d[i] - l[i - 1] * y[i - 1];
				}
				//  3. Backward substitutions U*x=y
				x[n - 1] = y[n - 1] / u[n - 1];
				for (i = n - 2; i >= 0; i--)
					x[i] = (y[i] - b[i] * x[i + 1]) / u[i];
			}
			void CubicSpline(double[] x, double[] y, int n, double[] xx, double[] yy, int yoffset, int m)
			{
				//CubicSpline return the Not-a-Knot spline values of array xx
				double[] dx = new double[n - 1];
				double[] divdiff = new double[n - 1];
				double[] pp;
				double xs;
				int i, j;

				for (i = 0; i < n - 1; i++)
				{
					dx[i] = x[i + 1] - x[i];
					divdiff[i] = (y[i + 1] - y[i]) / dx[i];
				}

				if (n == 2) //the interpolant is a straight line
				{
					for (i = 0; i < m; i++)
						yy[i+yoffset] = divdiff[0] * (xx[i] - x[0]) + y[0];
				}
				else if (n == 3) //the interpolant is a parabola
				{
					if (divdiff[1] != divdiff[0])
					{
						pp = new double[3];
						if (dx[1] != dx[0])
						{
							pp[2] = (divdiff[1] - divdiff[0]) / (dx[1] - dx[0]);
							pp[1] = divdiff[0] - pp[2] * dx[0];
							pp[0] = y[0] - x[0] * pp[1] - x[0] * x[0] * pp[2];
						}
						else
						{
							pp[2] = (y[2] - y[1] - (y[1] - y[0])) / (x[2] * x[2] - 2 * x[1] * x[1] + x[0] * x[0]);
							pp[1] = divdiff[0] - pp[2] * dx[0];
							pp[0] = y[0] - x[0] * pp[1] - x[0] * x[0] * pp[2];

						}
						for (i = 0; i < m; i++)
							yy[i+yoffset] = (pp[2] * xx[i] + pp[1]) * xx[i] + pp[0];

					}
					else // although there are three points, but they are on the same straight line
					{
						for (i = 0; i < m; i++)
							yy[i+yoffset] = divdiff[0] * (xx[i] - x[0]) + y[0];
					}
				}
				else
				{
					double[] d = new double[n];
					double[] D = new double[n];
					for (i = 1; i < n - 1; i++)
						d[i] = 3 * (dx[i] * divdiff[i - 1] + dx[i - 1] * divdiff[i]);
					double x31 = x[2] - x[0], xn = x[n - 1] - x[n - 3];
					d[0] = ((dx[0] + 2 * x31) * dx[1] * divdiff[0] + dx[0] * dx[0] * divdiff[1]) / x31;
					d[n - 1] = (dx[n - 2] * dx[n - 2] * divdiff[n - 3] + (2 * xn + dx[n - 2]) * dx[n - 3] * divdiff[n - 2]) / xn;
					double[] a, b, c;

					a = new double[n];
					b = new double[n - 1];
					c = new double[n - 1];
					a[0] = dx[1]; a[n - 1] = dx[n - 3];
					c[n - 2] = xn; b[0] = x31;
					for (i = 1; i < n - 1; i++)
					{
						a[i] = 2 * (dx[i] + dx[i - 1]);
						c[i - 1] = dx[i];
						b[i] = dx[i - 1];
					}
					TridiagSolve(a, b, c, d, D, n);
					for (i = 0; i < n - 1; i++)
					{
						c[i] = (3 * (divdiff[i]) - 2 * D[i] - D[i + 1]) / (dx[i]);
						d[i] = (-2 * (divdiff[i]) + D[i] + D[i + 1]) / (dx[i] * dx[i]);
					}
					bool bkinv;
					for (i = 0; i < m; i++)
					{
						if (xx[i] < x[0])
							j = 0;
						else if (xx[i] >= x[n - 1])
							j = n - 2;
						else
						{
							bkinv = true;
							j = 0;
							while (bkinv)  //find the inteval which xx[i] lies
							{
								if ((xx[i] < x[j + 1]) && (xx[i] >= x[j])) bkinv = false;
								else j++;

							}
						}
						xs = xx[i] - x[j]; //change the value to local coordinates
						yy[i+yoffset] = ((d[j] * xs + c[j]) * xs + D[j]) * xs + y[j];

					}
				}
			}
			void interp_p(double[] y, double[] x, int aqm)
			{
				int i, k, n;

				n = y.length;
				if( aqm == 4 )
				{
					for(k = 0; k < 4; k++)
						x[k] = Mq[k][0]*(2*y[0]- y[1]) + Mq[k][1]*y[0] + Mq[k][2]*y[1];

					for(i = 1; i < n -1 ; i++)
						for(k = 0; k < 4; k++)
						{
							x[4*i+k] = Mq[k][0]*y[i-1] + Mq[k][1]*y[i] + Mq[k][2]*y[i+1];
						}
					for(k = 0; k < 4; k++)
						x[(n-1)*4 + k] = Mq[k][0]*y[n-2] + Mq[k][1]*y[n-1] + Mq[k][2]*(2*y[n-1] - y[n-2]);
				}
				else if( aqm == 3 )
				{
					for(k = 0; k < 3; k++)
						x[k] = Mm[k][0]*(2*y[0]- y[1]) + Mm[k][1]*y[0] + Mm[k][2]*y[1];

					for(i = 1; i < n -1 ; i++)
						for(k = 0; k < 3; k++)
						{
							x[3*i+k] = Mm[k][0]*y[i-1] + Mm[k][1]*y[i] + Mm[k][2]*y[i+1];
						}
					for(k = 0; k < 3; k++)
						x[(n-1)*3 + k] = Mm[k][0]*y[n-2] + Mm[k][1]*y[n-1] + Mm[k][2]*(2*y[n-1] - y[n-2]);
				}
			}
			void interplinear(double[] y, double[] x, int aqm, EdfFreqConversionLineUpEnum lineup)
			{
				int i, k, n;
				double inc;

				n = y.length;
				if( lineup == (EdfFreqConversionLineUpEnum.First) )
				{
					for(i = 0; i < n - 1 ; i++)
					{
						inc = (y[i+1] - y[i])/aqm;
						for(k = 0; k < aqm; k++)
							x[aqm*i + k] = y[i] + k*inc;
					}
					inc = (y[n-1] - y[n-2]) / aqm;
					for(k = 0; k < aqm; k++)
				        x[aqm*(n-1) + k] = y[n-1] + k*inc;
				}
				else if (lineup == (EdfFreqConversionLineUpEnum.Center))
				{
					for(i = 0; i < n - 1; i++)
					{
						inc = (y[i+1] - y[i])/aqm;
						for(k = 0; k < aqm; k++)
							x[aqm*i + k] = y[i] - ((aqm -1.0)/2-k)*inc;
					}
					inc = (y[n - 1] - y[n - 2]) / aqm;
					for(k = 0; k < aqm; k++)
						x[aqm*(n-1) + k] = y[n-1] - ((aqm -1.0)/2-k)*inc;

				}
				else if (lineup == (EdfFreqConversionLineUpEnum.Average))
				{
					for(i = 0; i < n - 1; i++)
					{
						inc = (y[i+1] - y[i])/aqm;
						for(k = 0; k < aqm; k++)
							x[aqm*i + k] = y[i] - ((aqm -1.0)/2-k)*inc;
					}
					inc = (y[n - 1] - y[n - 2]) / aqm;
					for(k = 0; k < aqm; k++)
						x[aqm*(n-1) + k] = y[n-1] - ((aqm -1.0)/2-k)*inc;
				}
				else if (lineup == (EdfFreqConversionLineUpEnum.Last))
				{
					inc = (y[1] - y[0]) / aqm;
					for (k = 0; k < aqm; k++)
						x[k] = y[0] + (k - aqm + 1) * inc;
					for (i = 1; i < n; i++)
					{
						inc = (y[i] - y[i - 1]) / aqm;
						for (k = 0; k < aqm; k++)
							x[aqm * i + k] = y[i] + (k - aqm + 1) * inc;
					}
				}
				else
				{
					error_message_str = "lineup = " ~ to!string(lineup) ~ ". This is not a correct lineup. Valid lineups are average, center, first, or last.";
				}
			}
			void interpgeom(double[] y, double[] x, int aqm, EdfFreqConversionLineUpEnum lineup)
			{
				int i, k, n;
				double loginc;
				bool cneg = false;

				n = y.length;
				for (i = 0; i < n && !cneg; i++)
				{
					if (y[i] < 0)
					{
						warning_message_str = "Time series containing nonpositive values. Output series for geometric method contains missing values.";
						cneg = true;
					}
				}
				if( lineup == (EdfFreqConversionLineUpEnum.First))
				{
					for(i = 0; i < n - 1; i++)
					{
						loginc = std.math.log(y[i+1]/y[i])/aqm;
						for(k = 0; k < aqm; k++)
							x[aqm*i + k] = y[i]* std.math.exp(loginc*k);
					}

					loginc = std.math.log(y[n-1] / y[n-2]) / aqm;
					for (k = 0; k < aqm; k++)
						x[aqm * (n - 1) + k] = y[n - 1] * std.math.exp(loginc * k);
				}
				else if (lineup == (EdfFreqConversionLineUpEnum.Center))
				{
					for(i = 0; i < n - 1; i++)
					{
						loginc = std.math.log(y[i+1]/y[i])/aqm;
						for(k = 0; k < aqm; k++)
							x[aqm * i + k] = y[i] * std.math.exp(-((aqm - 1.0) / 2 - k) * loginc);
					}
					loginc = std.math.log(y[n - 1] / y[n - 2]) / aqm;
					for(k = 0; k < aqm; k++)
						x[aqm * (n - 1) + k] = y[n - 1] * std.math.exp(-((aqm - 1.0) / 2 - k) * loginc);

				}
				else if (lineup == (EdfFreqConversionLineUpEnum.Average))
				{   
					double factor;
					for(i = 0; i < n - 1; i++)
					{
						loginc = std.math.log(y[i+1]/y[i])/aqm;
						factor = 1.0;
						for(k = 1; k < aqm; k++)
							factor += std.math.exp(loginc * k);
						factor /= aqm;
						for(k = 0; k < aqm; k++)
							x[aqm * i + k] = y[i] * std.math.exp(loginc * k) / factor;
					}
					loginc = std.math.log(y[n - 1] / y[n - 2]) / aqm;
					factor = 1.0;
					for (k = 1; k < aqm; k++)
						factor += std.math.exp(loginc * k);
					factor /= aqm;
					for(k = 0; k < aqm; k++)
						x[aqm * (n - 1) + k] = y[n - 1] * std.math.exp(loginc * k) / factor;
				}
				else if (lineup == (EdfFreqConversionLineUpEnum.Last))
				{
					loginc = std.math.log(y[1] / y[0]) / aqm;
					for (k = 0; k < aqm; k++)
						x[k] = y[0] * std.math.exp((k - aqm + 1) * loginc);
					for (i = 1; i < n; i++)
					{
						loginc = std.math.log(y[i] / y[i - 1]) / aqm;
						for (k = 0; k < aqm; k++)
							x[aqm * i + k] = y[i] * std.math.exp((k - aqm + 1) * loginc);
					}
				}
				else
				{
					error_message_str = "lineup = " ~ to!string(lineup) ~ ". This is not a correct lineup. Valid lineups are average, center, first, or last.";
				}
			}
			void interpspline(double[] y, double[] x, int aqm, EdfFreqConversionLineUpEnum lineup)
			{
				// y is the input time series
				// x is the output time series

				int i, k, n;
				double inc, tmp;
				double [] tx, ty;

				n = y.length;
				tx = new double [n*aqm];
				ty = new double [n];

				if( lineup == (EdfFreqConversionLineUpEnum.First))
				{
					for(i = 0; i < n; i++)
						ty[i] = i;
					for(i = 0; i < n*aqm; i++)
						tx[i] = cast(double)i /aqm;
					CubicSpline(ty,y,n,tx,x,0,(n-1)*aqm+1);
					inc = (y[n-1]- y[n-2])/aqm;
					for(k = 1; k < aqm; k++)
						x[(n-1)*aqm+k] = y[n-1] + k*inc;
				}
				else if (lineup == (EdfFreqConversionLineUpEnum.Center))
				{
					for(i = 0; i < n; i++)
						ty[i] = i;
					if(aqm == 4)
					{
						for(i = 0; i < n*4; i++)
							tx[i] = i/4.0 + .125;

						//CubicSpline(ty,y,n,tx, x + 2,(n-1)*4);
						CubicSpline(ty, y, n, tx, x, 2, (n - 1) * 4);

						inc = (y[1]- y[0])/8;
						x[0] = y[0] - 3*inc;
						x[1] = y[0] - inc;
						inc = (y[n-1]- y[n-2])/8;
						x[4*n-2] = y[n-1] + inc;
						x[4*n-1] = y[n-1] + 3*inc;
					}
					else if(aqm == 3)
					{
						for(i = 0; i < n*3; i++)
							tx[i] = i/3.0;

						CubicSpline(ty,y,n,tx,x,1, (n-1)*3+1);

						inc = (y[1]- y[0])/6.0;
						x[0] = y[0] - 2*inc;
						inc = (y[n-1]- y[n-2])/6.0;
						x[3*n-1] = y[n-1] + 2*inc;
					}
				}
				else if (lineup == (EdfFreqConversionLineUpEnum.Average))
				{
					for(i = 0; i < n; i++)
						ty[i] = i;
					for(i = 0; i < n*aqm; i++)
						tx[i] = cast(double)i/aqm;
					CubicSpline(ty,y,n,tx,x,0, (n-1)*aqm+1);
					inc = (y[n-1]- y[n-2])/aqm;
					for(k = 1; k < aqm; k++)
						x[(n-1)*aqm+k] = y[n-1] + k*inc;
					for(i = 0; i < n; i++)
					{
						tmp = .0;
						for(k = 0; k < aqm; k++)
							tmp += x[i*aqm+k];
						tmp = y[i] - tmp/aqm;
						for(k = 0; k <  aqm; k++)
							x[i*aqm+k] += tmp;
					}
				}
				else if (lineup == (EdfFreqConversionLineUpEnum.Last))
				{
					for (i = 0; i < n; i++)
						ty[i] = i;
					for (i = 0; i < n * aqm; i++)
						tx[i] = (i + 1.0) / aqm;
					CubicSpline(ty, y, n, tx, x, aqm, (n - 1) * aqm);

					inc = (y[1] - y[0]) / aqm;
					// for (k = 0; k < n * aqm; k++)
					//     for (k = 0; k < aqm; k++)
					//     x[k] = y[0] - (aqm - k - 1) * inc;
					for (k = 0; k < aqm; k++)
                        x[k] = y[0] - (aqm - k - 1) * inc;

				}
				else
				{
					error_message_str = "lineup = " ~ to!string(lineup) ~ ". This is not a correct lineup. Valid lineups are average, center, first, or last.";
				}
			}
			public double[] interpsplinefun(double[] y, int scheme, EdfFreqConversionLineUpEnum lup)
			{
				int aqm = 1, nel = 0;
				warning_message_str = "";
				error_message_str = "";
				if (scheme == 1)      //annually to quarterly
					aqm = 4;
				else if (scheme == 2) // quarterly to  monthly
					aqm = 3;

				nel = y.length; // number of elements in the array
				double[] x = new double[nel * aqm];
				interpspline(y, x, aqm, lup);
				return x;
			}
			public double[] interplinearfun(double[] y, int scheme, EdfFreqConversionLineUpEnum lup)
			{
				int aqm = 1, nel = 0;

				warning_message_str = ""; 
				error_message_str = "";
				if (scheme == 1)      // annually to quarterly
					aqm = 4;
				else if (scheme == 2) // quarterly to  monthly
					aqm = 3;

				nel = y.length; // number of elements in the array
				double[] x = new double[nel * aqm];
				interplinear(y, x, aqm, lup);
				return x;
			}
			public double[] interpgeomfun(double[] y, int scheme, EdfFreqConversionLineUpEnum lup)
			{
				int aqm = 1, nel = 0;

				warning_message_str = ""; 
				error_message_str = "";
				if (scheme == 1)      // annually to quarterly
					aqm = 4;
				else if (scheme == 2) // quarterly to  monthly
					aqm = 3;
				nel = y.length; // number of elements in the array
				double[] x = new double[nel * aqm];
				interpgeom(y, x, aqm, lup);
				return x;
			}
			public double[] interp_pfun(double[] y, int scheme)
			{
				int aqm  = 0;

				warning_message_str = "";
				error_message_str = "";

				if  (scheme == 1)     // annually to quarterly
					aqm = 4;
				else if (scheme == 2) // quarterly to  monthly
					aqm = 3;
				else if (scheme == 3) // annually to monthly
					aqm = 12;
				else
				{
					error_message_str = "scheme = " ~ to!string(scheme) ~ "This is not a correct scheme. scheme must be 1 for annual to quarterly conversion or 2 for quarterly to monthly conversion or 3 for annual to monthly conversion.";
				}
				double [] x = new double[y.length * aqm];

				if (aqm > 0)
				{
					interp_p(y, x, aqm);
				}
				return x;
			}
			public double[] Compoundgrowth(double[] y, int interval, string fqstr, double proportion)
			{
				double fq = 0;
				int nel  = y.length;  //number of elements

				warning_message_str = ""; 
				error_message_str   = "";

				double[] x = new double[nel];

				if(fqstr == "annually")
					fq = 1.0;
				else if (fqstr == "quarterly")
					fq = 4.0;
				else if (fqstr == "monthly")
					fq = 12.0;
				else
				{
					error_message_str = "Frequency can only be equal annually, or quarterly or monthly!";

				}
				for (int i = 0; i < interval; i++)
					x[i] = std.math.NaN(0);
				if (fq > 0)
				{
					if (interval <= 0)
					{
						warning_message_str = "interval = " ~ to!string(interval) ~ ". interval must be positive number.";
					}
					else if (interval >= nel)
					{
						warning_message_str = "interval = " ~ to!string(interval) ~ ". interval must be less than length of input series.";
					}

					for (int i = interval; i < nel; i++)
					{
						try
						{
							x[i] = (std.math.pow(y[i] / y[i - interval], fq / interval) - 1.0) * proportion;
						}
						catch
						{
							warning_message_str = " Divided by 0!";
							x[i] = std.math.NaN(0);
						}
					}
				}            
				return x;
			}
			public double[] difffun(double [] y, int n)
			{
				int i, nel  = 0;
				// return the simple differences for series lagged by "n" periods in array x  
				warning_message_str = ""; 
				error_message_str   = "";
				nel = y.length; // number of elements in the array
				double[] x = new double[nel];
				if(n <= 0)
				{
					error_message_str ~= "n = " ~ to!string(n) ~ ". It is not a proper value for n. n must be a positive integer!";
					for(i = 0; i < nel; i++)
						x[i] = std.math.NaN(0);

				}
				else if( n > nel)
				{
					error_message_str ~= "n = " ~ to!string(n) ~ ". n must be less than or equal to the length of input series!";
					for(i = 0; i < nel; i++)
						x[i] = std.math.NaN(0);

				}
				else if( nel  > 0 )
				{
					for(i = 0; i < n; i++)
					{
						x[i] = std.math.NaN(0);
					}
					for( i = n; i < nel; i++)
					{     
						x[i] = y[i] - y[i-n];
					}
				}
				return x;
			}
			public double[] differencefun(double [] y, int n)
			{
				//   Differences which approximate derivative.
				//   differencefun(y,1), for a vector y, is 
				//	 [STL_NaN, y(2)-y(1),  y(3)-y(2), ..., y(n)-y(n-1)].
				//   differencefun(x,n) is the n-th order difference 
				double [] x;
				double tmp1, tmp2;
				int i,j, nel  = 0;
				warning_message_str = ""; 
				error_message_str = "";
				nel = y.length; // number of elements in the array

				x = new double[nel];
				if(n <= 0)
				{
					error_message_str ~= "n = " ~ to!string(n) ~ ". It is not a proper value for n. n must be a positive integer!";
					for(i = 0; i < nel; i++)
						x[i] = std.math.NaN(0);
				}
				else if( n > nel)
				{
					warning_message_str ~= "n = " ~ to!string(n) ~". n must be less than or equal to the length of input series!";
					for(i = 0; i < nel; i++)
						x[i] = std.math.NaN(0);
				}
				else if( nel  > 0 )
				{
					for(i = 0; i < nel; i++)
					{
						x[i] = y[i];
					}
					for( i = 0; i < n; i++)
					{
						tmp1 = x[i];
						x[i] = std.math.NaN(0);
						for( j = 1+i; j < nel; j++)
						{   
							tmp2   = x[j];
							x[j] -= tmp1;
							tmp1   = tmp2;
						}	
					}
				}
				return x;
			}
			public double[] Freqconversionfun(double[] y, EdfFreqConversionMethEnum method, int scheme, EdfFreqConversionLineUpEnum lineup)
			{
				int aqm = 1, nel, i, k;
				bool cNaN = false;
				double inc;

				warning_message_str = ""; 
				error_message_str = "";

				if(scheme == 1)      // annually to quarterly
					aqm = 4;
				else if(scheme == 2) // quarterly to  monthly
					aqm = 3;
				else if (scheme == 3) // annually to monthly
					aqm = 12;
				else
				{
					error_message_str = "scheme = " ~ to!string(scheme) ~ "This is not a correct scheme. scheme must be 1 for annual to quarterly conversion or 2 for quarterly to monthly conversion or 3 for annual to monthly conversion.";
				}
				nel = y.length; // number of elements in the array
				double[] x = new double[nel * aqm];
				for(i = 0; i < nel&&!cNaN; i++)
					if(std.math.isNaN(y[i]))
					{
						error_message_str = "The input series contains missing values.";
						cNaN = true;
					}

				if (aqm == 1 || cNaN)
				{
					for (i = 0; i < nel; i++)
						x[i] = std.math.NaN(0);
				}
				else if(aqm == 4 || aqm == 3)
				{
					if (method == (EdfFreqConversionMethEnum.Linear))
						interplinear(y, x, aqm, lineup);
					else if (method == (EdfFreqConversionMethEnum.Geometric))
						interpgeom(y, x, aqm, lineup);
					else if (method == (EdfFreqConversionMethEnum.Spline))
						interpspline(y, x, aqm, lineup);
					else if (method == (EdfFreqConversionMethEnum.Last))
						for (i = 0; i < nel; i++)
						{
							inc = y[i];
							for (k = 0; k < aqm; k++)
								x[aqm * i + k] = inc;
						}
					else
					{
						error_message_str ~= "method = " ~ to!string(method) ~ " This is not a correct method. Valid methods are linear, geometric, or spline.";
						for (i = 0; i < nel * aqm; i++)
							x[i] = std.math.NaN(0);
					}
				}
				else if(aqm == 12)
				{
					double [] pxtmp = new double [nel*4];
					if (method == (EdfFreqConversionMethEnum.Linear))
					{
						interplinear(y, pxtmp, 4, lineup);
						interplinear(pxtmp, x, 3, lineup);
					}
					else if (method == (EdfFreqConversionMethEnum.Geometric))
					{
						interpgeom(y, pxtmp, 4, lineup);
						interpgeom(pxtmp, x, 3, lineup);
					}
					else if (method == (EdfFreqConversionMethEnum.Spline))
					{
						interpspline(y, pxtmp, 4, lineup);
						interpspline(pxtmp, x, 3, lineup);
					}
					else if (method == (EdfFreqConversionMethEnum.Last))
						for (i = 0; i < nel; i++)
						{
							inc = y[i];
							for (k = 0; k < aqm; k++)
								x[aqm * i + k] = inc;
						}
					else
					{
						error_message_str = "method = " ~ to!string(method) ~ " This is not a correct method. Valid methods are linear, geometric, or spline";
						for (i = 0; i < nel * aqm; i++)
							x[i] = std.math.NaN(0);
					}
				}
				return x;
			}
			public double[] Replacemissingfun(double[] y, EdfFormatEnum fmthd, double[][] list...)
			{
				int i, k, nel = 0, numoflist = 0;
				numoflist = list.length;
				//warning_message_str = ""; 
				error_message_str = "";
				nel = y.length; // number of elements in the array
				double[] x = new double[nel];

				if (fmthd == (EdfFormatEnum.Linear))
				{
					// locate the first legal number, i.e. not a NaN
					k = 0;
					while (std.math.isNaN(y[k]))
					{
						k++;
					}
					// From the first element to this element, we just copy them to the new array
					for (i = 0; i <= k; i++) x[i] = y[i];
					// Locate the next legal number, i.e. not a NaN and interpolate the intermediate
					// NaN elements
					for (i = k + 1; i < nel; i++)
					{
						if (!std.math.isNaN(y[i]))
						{
							x[i] = y[i];
							if (i - k > 1)
							{
								for (int j = k + 1; j < i; j++)
									x[j] = y[k] + (y[i] - y[k]) * (j - k) / (i - k);
							}
							k = i;
						}
					}
					if (k < nel - 1) // This means that from k+1 to nel-1 all are NaNs, 
					{                // we can do nothing about them, just copy to the new array
						for (i = k + 1; i < nel; i++)
							x[i] = y[i];
					}
				}
				else if (fmthd == (EdfFormatEnum.Repeat))
				{
					bool sortmode = false;
					try
					{
						sortmode = cast(bool)list[0][0];
					}
					catch
					{
						warning_message_str = " sortmode must be bool, default value of sortmode(false) is used.";
					}
					if (!sortmode) // use previous NaN to fill in
					{
						// locate the first legal number, i.e. not a NaN
						k = 0;
						while (std.math.isNaN(y[k]))
						{
							k++;
						}
						// From the first element to this element, we just copy them to the new array
						for (i = 0; i <= k; i++) x[i] = y[i];
						// loop through the rest part of the array, if it is NaN
						// replace it by previous value
						for (i = k + 1; i < nel; i++)
						{
							if (std.math.isNaN(y[i]))
								x[i] = x[i - 1];
							else
								x[i] = y[i];
						}
					}
					else if (sortmode) // use right next value
					{
						// locate the last legal number, i.e. not a NaN
						k = nel - 1;
						while (std.math.isNaN(y[k]))
						{
							k--;
						}
						// From the last element to this element, we just copy them to the new array
						for (i = nel - 1; i >= std.math.fmax(k, 0); i--) x[i] = y[i];
						// loop through the rest part of the array, if it is NaN
						// replace it by right next value
						for (i = k - 1; i >= 0; i--)
						{
							if (std.math.isNaN(y[i]))
								x[i] = x[i + 1];
							else
								x[i] = y[i];
						}
					}
				}
				else if (fmthd == (EdfFormatEnum.Geometric))
				{
					// locate the first legal number, i.e. not a NaN
					k = 0;
					while (std.math.isNaN(y[k]))
					{
						k++;
					}
					// From the first element to this element, we just copy them to the new array
					for (i = 0; i <= k; i++) x[i] = y[i];
					// Locate the next legal number, i.e. not a NaN and interpolate the intermediate
					// NaN elements
					for (i = k + 1; i < nel; i++)
					{
						if (!std.math.isNaN(y[i]))
						{
							x[i] = y[i];
							if (i - k > 1)
							{
								for (int j = k + 1; j < i; j++)
									x[j] = y[k] * std.math.exp(std.math.log(y[i] / y[k]) * (j - k) / (i - k));
							}
							k = i;
						}
					}
					if (k < nel - 1) // This means that from k+1 to nel-1 all are NaNs, 
					{                // we can do nothing about them, just copy to the new array
						for (i = k + 1; i < nel; i++)
							x[i] = y[i];
					}
				}
				else if (fmthd == (EdfFormatEnum.Overlay))
				{
					double[] z = y;
					z = list[1];
					int nelp = z.length; // number of elements in the array
					if (nelp < nel)
					{
						warning_message_str = "The length of proxyser is less than that of y. NaNs could exsit in output series.";
					}
					for (i = 0; i < nel; i++)
					{
						if (std.math.isNaN(y[i]) && i < nelp)
						{
							x[i] = z[i]; // replace it by corresponding value in the provided array
						}
						else
						{
							x[i] = y[i];
						}
					}
				}
				else if (fmthd == (EdfFormatEnum.Ovalue))
				{
					double value = 0;
					if (numoflist > 0)
					{
						value = cast(double)list[0][0];
					}
					for (i = 0; i < nel; i++)
					{
						if (std.math.isNaN(y[i]))
						{
							x[i] = value; // replace it by provided value
						}
						else
						{
							x[i] = y[i];
						}
					}
				}
				return x;
			}
			public double[] movavgfun(double[] y, int n)
			{
				double tmp  = 0.0;
				int i, nel  = 0;

				warning_message_str = ""; 
				error_message_str = "";
				nel = y.length; // number of elements in the array
				double[] x = new double[nel];

				if(n <= 0)
				{
					error_message_str = "n = " ~ to!string(n) ~ ". It is not a proper value for n. n must be a positive integer!";
					for(i = 0; i < nel; i++)
						x[i] = std.math.NaN(0);
				}
				else if( n > nel)
				{
					warning_message_str ~= "n = " ~ to!string(n) ~ ". n must be less than or equal to the length of input series!";
					for(i = 0; i < nel; i++)
						x[i] = std.math.NaN(0);
				}
				else if( nel  > 0 )
				{
					for(i = 0; i < n-1; i++)
					{
						tmp += y[i];
						x[i] = std.math.NaN(0);
					}
					for( i = n-1; i < nel; i++)
					{     
						tmp += y[i];
						x[i] = tmp/n;
						tmp -= y[i-(n-1)];
					}
				}
				return x;
			}
    }  // close of class Datainterp


