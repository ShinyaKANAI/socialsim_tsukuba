; ######################################
; グローバル変数の定義
globals [
  contact-rate-home-hospital  ;自宅と病院の接触率
  contact-rate-work-school    ;職場と学校の接触率
  contagious-rate-high        ;高感染率
]

; ######################################
; タートル変数の定義
turtles-own [
  town          ;町
  adult         ;大人
  medical-staff ;病院勤務者
  destination   ;通勤通学先
  contagious    ;感染
  hxc           ;homeのx座標
  hyc           ;homeのy座標
  cdays         ;感染日数
  place         ;現在地 0:home, 1:work or school, 3:hospital, 4:morg
]

; ######################################
; セットアップ命令開始
to setup
  ; グローバル変数の設定
  clear-all
  set contact-rate-home-hospital 1.0
  set contact-rate-work-school 0.3
  set contagious-rate-high contagious-rate-low * 2

  ; 背景の設定
  ask patches [
    if pxcor <= 0 and pycor >= 0 [ set pcolor 52 ]
    if pxcor <= 0 and pycor <= 0 [ set pcolor 82 ]
    if pxcor >= 0 and pxcor <= max-pxcor and pycor >= 0 [ set pcolor 53 ]
    if pxcor >= 0 and pxcor <= max-pxcor and pycor <= 0 [ set pcolor 83 ]
    if pxcor >= 10 and pxcor <=  20 and pycor >= -5 and pycor <= 5 [ set pcolor 7 ]
    if pxcor >= 22 and pxcor <=  32 and pycor >= -5 and pycor <= 5 [ set pcolor 5 ]
  ]

  ;square townの住民
  let xc 0
  let yc 0
  let iv1 3
  let iv2 1
  create-turtles 100 [
    set color blue
    set shape "square"
    set town "square"
    set destination "square"
    set adult true
    set contagious 0
    set place 0
    set cdays -1
    setxy (min-pxcor + xc * iv1 + 5) (max-pycor - yc - 5)
    set xc xc + 1
    if xc >= 10 [
      set xc 0
      set yc yc + iv1
    ]
    hatch 1 [
      setxy xcor + iv2 ycor
    ]
    hatch 1 [
      set color 106
      set adult false
      setxy xcor ycor - iv2
    ]
    hatch 1 [
      set color 106
      set adult false
      setxy xcor + iv2 ycor - iv2
    ]
  ]

  ;circle townの住民
  ;ここにCircle townの住民エージェントの生成コードを入力
  set xc 0
  set yc 0
  set iv1 3
  set iv2 1
  create-turtles 100 [
    set color blue
    set shape "circle"
    set town "circle"
    set destination "circle"
    set adult true
    set contagious 0
    set place 0
    set cdays -1
    setxy (min-pxcor + xc * iv1 + 5) (0 - yc - 5)
    set xc xc + 1
    if xc >= 10 [
      set xc 0
      set yc yc + iv1
    ]
    hatch 1 [
      setxy xcor + iv2 ycor
    ]
    hatch 1 [
      set color 106
      set adult false
      setxy xcor ycor - iv2
    ]
    hatch 1 [
      set color 106
      set adult false
      setxy xcor + iv2 ycor - iv2
    ]
  ]

  ;homeの位置を記憶
  ask turtles [
    set hxc xcor
    set hyc ycor
    set contagious 0
    set medical-staff false
  ]

  ;医療従事者を設定
  ask n-of 5 turtles with [adult = true and town = "square"][
    set medical-staff true
  ]
  ask n-of 5 turtles with [adult = true and town = "circle"][
    set medical-staff true
  ]

  ;隣町へ通う人を設定
  ask n-of 20 turtles with [adult = true and town = "square" and medical-staff = false][
    set destination "circle"
  ]
  ask n-of 20 turtles with [adult = true and town = "circle" and medical-staff = false][
    set destination "square"
  ]

  ;1人が感染
  ask one-of turtles [
    set contagious 1
    set color green
    set cdays 0
  ]

  ;; start the clock
  reset-ticks
end

; ######################################
;以下にgoプロシージャを記述する
to go
  move2work-school ;通勤通学
  contagion ; 感染処理
  display ;画面更新
  ; wait wait-t; 表示待ち時間
  move2home ;帰宅
  contagion ; 感染処理
  display
  ; wait wait-t; 表示待ち時間
  add-days ; 感染日数
  ;停止条件
  if count turtles with [color = green or color = yellow or color = red or color = orange] = 0 [stop]
  tick ;時間更新
end

; ######################################
;職場か学校に通う
to move2work-school

  ; squareの職場に行く
  let xc 0
  let yc 0
  let iv1 1
  ask turtles with [destination = "square" and adult = true and medical-staff = false and place <= 1][
    setxy (10 + xc * iv1 ) (max-pycor - 10 - yc)
    set xc xc + 1
    if xc >= 10 [
      set xc 0
      set yc yc + iv1
    ]
    set place 1
  ]

  ; squareの学校に行く
  set xc 0
  set yc 0
  ask turtles with [destination = "square" and adult = false and place <= 1][
    setxy (22 + xc * iv1 ) (max-pycor - 10 - yc)
    set xc xc + 1
    if xc >= 10 [
      set xc 0
      set yc yc + iv1
    ]
    set place 1
  ]

  ; circleの職場に行く
  set xc 0
  set yc 0
  ask turtles with [destination = "circle" and adult = true and medical-staff = false and place <= 1][
    setxy (10 + xc * iv1 ) ( - 10 - yc)
    set xc xc + 1
    if xc >= 10 [
      set xc 0
      set yc yc + iv1
    ]
    set place 1
  ]

  ; circleの学校に行く
  set xc 0
  set yc 0
  ask turtles with [destination = "circle" and adult = false and place <= 1][
    setxy (22 + xc * iv1 ) ( - 10 - yc)
    set xc xc + 1
    if xc >= 10 [
      set xc 0
      set yc yc + iv1
    ]
    set place 1
  ]

  ;病院へ通う
  ask turtles with [medical-staff = true and place < 2][
    setxy (random-float 10) + 10 (random-float 10) - 5
    set place 1
  ]

end

; ######################################
;以下に自宅に戻るmove2homeプロシージャを記述する
to move2home
  ask turtles with [place < 2][
    setxy hxc hyc
    set place 0
  ]
end

; ######################################
;接触・感染
to contagion
  let contact-rate 0
  let contagious-rate 0
  ask turtles with [contagious = 1][
    ;感染して12日間は症状が出ない潜伏期（緑）
    if cdays >= 0 and cdays <= 11 [set color green]

    ;感染して4日目までにワクチンを打たないと羅漢してしまう
    ;12日を過ぎると発熱症状が出て人に感染するが、天然痘かどうかは不明（黄）
    if cdays >= 12 and cdays <= 15 [set color yellow]

    ;15日を過ぎると発疹が出て、天然痘とわかる（赤）
    ;16日〜19日の感染率は、12日〜15日の感染率の2倍
    if cdays >= 15 and cdays <= 19 [set color red]

    ;この状態で翌日（12時間後）に病院に搬送される
    if cdays = 16 [set place 2] ;病院へ

    ;20日以降の感染率は、12日〜15日と同じ
    ;発疹の最終期は12日の伝染力の値に戻る
    if cdays >= 20 and cdays <= 23 [set color orange]

    ;16〜23日の死亡率は30％（黒）
    if cdays >= 16 and cdays <= 23 [
      if random-float 1 < (0.3 / 8) [
        set color black
        set place 3
        set contagious 2
        set cdays -1
      ]
    ]

    ;残りは回復して、免疫を持つ（白）
    if cdays = 24 and color != black [
      set color white
      ;自宅に戻る
      set place 0
      set cdays -1
    ]

    ;病院へ移動
    if place = 2 [
      setxy  (random-float 10) + 10 (random-float 10) - 5
    ]

    ;安置所へ移動
    if place = 3 [
      setxy  (random-float 10) + 22 (random-float 10) - 5
    ]

    ;場所によって接触率が異なる
    if place = 0  [set contact-rate contact-rate-home-hospital]
    if place = 1  [set contact-rate contact-rate-work-school]
    if place = 2  [set contact-rate contact-rate-home-hospital]

    ;感染日数で感染率が異なる
    if color = green [set contagious-rate 0]
    if color = yellow or color = orange [set contagious-rate contagious-rate-low]
    if color = red [set contagious-rate contagious-rate-high]

    ;以下にムーア近傍の人に感染するコードを記述する
    ask turtles-on neighbors[
      if contagious = 0 [
        if (random-float 1) < contact-rate * contagious-rate [
          set contagious 1
          set cdays 0
        ]
      ]
    ]


  ]

end

; ######################################
;以下に感染者は経過日数を更新するadd-daysプロシージャを記述する
to add-days
  ask turtles with [cdays >= 0][
    set cdays cdays + 1
  ]
end

@#$#@#$#@
GRAPHICS-WINDOW
237
11
812
587
-1
-1
7.0
1
24
1
1
1
0
1
1
1
-40
40
-40
40
0
0
1
ticks
30.0

BUTTON
20
26
86
59
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
95
27
158
60
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
25
77
206
110
contagious-rate-low
contagious-rate-low
0
1
0.2
0.1
1
NIL
HORIZONTAL

MONITOR
27
131
94
176
Fatalities
count turtles with [color = black]
17
1
11

MONITOR
105
130
162
175
Days
ticks
17
1
11

PLOT
31
193
231
343
Number of infected people
Time
Rate
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"Infected" 1.0 0 -2674135 true "" "plot count turtles with [(color = green) or (color = yellow) or (color = red) or (color = orange)] / (count turtles)"
"Dead" 1.0 0 -16777216 true "" "plot count turtles with [color = black] / (count turtles)"
"Recovered" 1.0 0 -13345367 true "" "plot count turtles with [color = white] / (count turtles)"

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
