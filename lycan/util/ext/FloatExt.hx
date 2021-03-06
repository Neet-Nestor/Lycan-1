package lycan.util.ext;

// Extension methods for Floats
class FloatExt {
	public static inline function clamp(v:Float, min:Float, max:Float):Float {
		return (v < min ? min : (v > max ? max : v));
	}

	public static inline function inRangeInclusive<T:Float>(p:T, x1:T, x2:T):Bool {
		return (p >= Math.min(x1, x2) && p <= Math.max(x1, x2));
	}

	public static inline function inRangeExclusive<T:Float>(p:T, x1:T, x2:T):Bool {
		return (p > Math.min(x1, x2) && p < Math.max(x1, x2));
	}

	public static inline function lerp(v:Float, a:Float, b:Float):Float {
		return (b - a) * v + a;
	}

	public static inline function coslerp(v:Float, a:Float, b:Float):Float {
		var c:Float = (1 - Math.cos(v * Math.PI)) / 2;
		return a * (1 - c) + b * c;
	}

	public static inline function sign(x:Float):Float {
		return x > 0 ? 1 : x < 0 ? -1 : 0;
	}

	public static inline function floatPart(x:Float):Float {
		return x < 0 ? 1 - (x - Math.floor(x)) : x - Math.floor(x);
	}

	public static inline function wrap(x:Float, lower:Float, upper:Float):Float {
		if (lower > upper) {
			throw("Lower bound must be less than upper bound");
		}
		var range = upper - lower + 1;
		x = ((x - lower) % range);
		if (x < 0) {
			return upper + 1 + x;
		} else {
			return lower + x;
		}
	}
}