module Collision
  ( axisAlignedBoundingBox
  , circleToCircle
  , Side(Top, Right, Bottom, Left)
  , rectangleSide
  , Rectangle
  , rectangle
  , Circle
  , circle
  ) where

{-| Detect collision/intersection of geometry in a defined coordinate space
AKA tell me when objects are touching or overlapping

# Basic geometry
@docs Rectangle, rectangle, Circle, circle

# Rectangle to Rectangle Collision
@docs axisAlignedBoundingBox, rectangleSide, Side

# Circle to Circle Collision
@docs circleToCircle
-}


{-| Represents rectangular hitbox geometry.
-}
type Rectangle = Rectangle { cx: Float, cy: Float, w : Float, h : Float }


{-| Create a Rectangle hitbox from geometry (width and height) and coordinates (cx, cy)

    rectangle 5 5 10 10
    -- a 10 x 10 rectangle centered on coordinates 5,5
-}
rectangle : Float -> Float -> Float -> Float -> Rectangle
rectangle centerX centerY width height =
  Rectangle { cx = centerX, cy = centerY, w = width, h = height }


{-| Represents circular geometry.
-}
type Circle = Circle { cx: Float, cy: Float, radius : Float }


{-| Create a Circle Hitbox from geometry (radius) and coordinates (cx, cy)

    circle 5 5 10 -- a radius 10 circle centered on coordinates 5,5
-}
circle : Float -> Float -> Float -> Circle
circle centerX centerY radius =
  Circle { cx = centerX, cy = centerY, radius = radius }


{-| Detect collision between two Rectangles that
are axis aligned — meaning no rotation.

    rect1 = { cx = 5, cy = 5, w = 10, h = 10 }
    rect2 = { cx = 7, cy = 5, w = 10, h = 10 }

    axisAlignedBoundingBox rect1 rect2 -- True
    -- rect1 is coliding with rect2
-}
axisAlignedBoundingBox : Rectangle -> Rectangle -> Bool
axisAlignedBoundingBox r1 r2 =
  case r1 of
    Rectangle rect1 ->
      case r2 of
        Rectangle rect2 ->
          let
            startingPoint centerPoint length = centerPoint - (length / 2)
            x1 = startingPoint rect1.cx rect1.w
            x2 = startingPoint rect2.cx rect2.w
            y1 = startingPoint rect1.cy rect1.h
            y2 = startingPoint rect2.cy rect2.h
          in
            if x1 < x2 + rect2.w &&
               x1 + rect1.w > x2 &&
               y1 < y2 + rect2.h &&
               rect1.h + y1 > y2 then
              True
            else
              False


{-| Detect collision between two Circles

    circle1 = { cx = 5, cy = 5, radius = 5 }
    circle2 = { cx = 7, cy = 5, radius = 5 }

    circleToCircle circle1 circle2 -- True
    -- circle1 is coliding with circle2
-}
circleToCircle : Circle -> Circle -> Bool
circleToCircle c1 c2 =
  case c1 of
    Circle circle1 ->
      case c2 of
        Circle circle2 ->
          let
            dx = circle1.cx - circle2.cx
            dy = circle1.cy - circle2.cy
            distance = sqrt ((dx * dx) + (dy * dy))
          in
            if distance < circle1.radius + circle2.radius then
              True
            else
              False


{-| Represents sides of a Rectangle
-}
type Side
  = Top
  | Right
  | Bottom
  | Left


{-| Detect which side of a Rectangle is colliding with another Rectangle

    rect1 = { cx = 5, cy = 5, w = 10, h = 10 }
    rect2 = { cx = 7, cy = 5, w = 10, h = 10 }

    rectangleSide rect1 rect2 -- Just Right
    -- rect1 is coliding with it's right side onto rect2
-}
rectangleSide : Rectangle -> Rectangle -> Maybe Side
rectangleSide r1 r2 =
  {-
    Calculate which side of a rectangle is colliding w/ another, it works by
    getting the Minkowski sum of rect2 and rect1, then checking where the centre of
    rect1 lies relatively to the new rectangle (from Minkowski) and to its diagonals
    * thanks to sam hocevar @samhocevar for the formula!
  -}
  case r1 of
    Rectangle rect1 ->
      case r2 of
        Rectangle rect2 ->
          let
            w = 0.5 * (rect1.w + rect2.w)
            h = 0.5 * (rect1.h + rect2.h)
            dx = rect2.cx - rect1.cx
            dy = rect2.cy - rect1.cy
            wy = w * dy
            hx = h * dx

          in
            if abs dx <= w && abs dy <= h then
              if (wy > hx) then
                if (wy > -hx) then
                  Just Top
                else
                  Just Left
              else
                if (wy > -hx) then
                  Just Right
                else
                  Just Bottom
            else
              Nothing
