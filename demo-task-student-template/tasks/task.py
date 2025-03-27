import math

def solution(a, b, c):
    if a == 0:
        return None

    delta = b**2 - 4*a*c

    if delta < 0:
        return None
    elif delta == 0:
        x = -b // (2*a)
        return (x,)
    else:
        sqrt_delta = math.isqrt(delta)
        if sqrt_delta * sqrt_delta != delta:
            return None

        x1 = (-b - sqrt_delta) // (2*a)
        x2 = (-b + sqrt_delta) // (2*a)
        return tuple(sorted((x1, x2)))
