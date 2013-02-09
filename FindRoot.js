// Root Finder

// xmin - first guess
// xmax - second guess
// f - function to evaluate. Takes one numeric value, returns one numeric value

function findRoot(f, regs, i, x)
{
    var xmin = x;
    var xmax = regs[i];

    if (xmin > xmax) {
        var tmp = xmin;
        xmin = xmax;
        xmax = tmp;
    }
    else if (xmin == xmax)
        xmax = xmin + 1;
    
    var ymin = execf(f, regs, i, xmin);
    var ymax = execf(f, regs, i, xmax);

    if (sign(ymin) == sign(ymax)) {
        // Find a better guess
        if (ymin < 0) {
            if (ymin < ymax)
                xmin = xmax;
            
            xmax = findGuess(f, regs, i, xmin, xmax > xmin);
        }
        else {
            if (ymax < ymin)
                xmax = xmin;
            
            xmin = findGuess(f, regs, i, xmax, xmax < xmin);
        }
    }

    var xmid = xmin;
    
    while (Math.abs(xmax - xmin) > 1e-34) {
        // Calculate xmid of domain
        var xmid = (xmax + xmin) / 2;

        // Find f(xmid)
        if (execf(f, regs, i, xmin) * execf(f, regs, i, xmid) < 0) {
            // Throw away xmax
            xmax = xmid;
        }
        else if (execf(f, regs, i, xmax) * execf(f, regs, i, xmid) < 0) {
            // Throw away xmin
            xmin = xmid;
        }
        else {
            // Our midpoint is exactly on the root
            break;
        }
    }
    return xmid;
}

function sign(x) { return (x >= 0) ? 1 : -1; }

function execf(f, regs, i, x)
{
    regs[i] = x;
    return f(regs);
}

function findGuess(f, regs, i, x, increasing)
{
    sgn = (x < 0 ^ !increasing) ? -1 : 1;
    xdelta = 0.1 * sgn;

    for (var maxIters = 0; maxIters < 1000 && execf(f, regs, i, x + xdelta) * sgn < 0; ++maxIters)
        xdelta *= 2;

    return x + xdelta;
}

    