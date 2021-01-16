package feint.utils;

import haxe.ds.Either;

class Math {
  public static function clampFloat(num:Float, min:Float, max:Float) {
    if (num < min) {
      return min;
    }
    if (num > max) {
      return max;
    }
    return num;
  }

  public static function clamp<T>(num:OneOf<Int, Float>, min:T, max:T):T {
    return switch (num) {
      case Left(i): {
          if (i < cast(min, Int)) {
            return min;
          }
          if (i > cast(max, Int)) {
            return max;
          }
          return cast i;
        }
      case Right(f): {
          if (f < cast(min, Float)) {
            return min;
          }
          if (f > cast(max, Float)) {
            return max;
          }
          return cast f;
        }
    }
  }
}

abstract OneOf<A, B>(Either<A, B>) from Either<A, B> to Either<A, B> {
  @:from inline static function fromA<A, B>(a:A):OneOf<A, B> {
    return Left(a);
  }

  @:from inline static function fromB<A, B>(b:B):OneOf<A, B> {
    return Right(b);
  }

  @:to inline function toA():Null<A> {
    return switch (this) {
      case Left(a): a;
      default: null;
    }
  }

  @:to inline function toB():Null<B> {
    return switch (this) {
      case Right(b): b;
      default: null;
    }
  }
}
