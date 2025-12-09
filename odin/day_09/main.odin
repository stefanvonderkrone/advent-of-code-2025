package main

import "../iterator"
import "core:bufio"
import "core:fmt"
import "core:io"
import "core:math"
import "core:math/linalg"
import "core:os"
import "core:slice"
import "core:sort"
import "core:strconv"
import "core:strings"

INPUT_TEST :: "input_test.txt"
INPUT_01 :: "input_01.txt"

main :: proc() {
	filename :: INPUT_01
	file_handle, err_handle := os.open(filename)
	if err_handle != nil {
		fmt.eprintln(err_handle)

	}
	defer os.close(file_handle)

	stream := os.stream_from_handle(file_handle)
	it: iterator.Iterator
	iterator.iterator_init(&it, &stream)

	points: [dynamic]Point

	for {
		str, ok := iterator.iterator_read(&it, '\n')

		if !ok {
			break
		}

		splits := strings.split(str, ",")
		x, _ := strconv.parse_int(splits[0])
		y, _ := strconv.parse_int(splits[1])

		// fmt.printfln("%s", str)

		append(&points, Point{x, y})

	}

	run_02(points[:])
}

run_02 :: proc(points: []Point) {
	num_points := len(points)

	rects: [dynamic]Rectangle

	for i in 0 ..< num_points - 1 {
		for j in i + 1 ..< num_points {
			p1 := points[i]
			p2 := points[j]

			// fmt.printfln("%v, %v", p1, p2)


			a := p2.x - p1.x
			if a < 0 {
				a *= -1
			}
			a += 1
			b := p2.y - p1.y
			if b < 0 {
				b *= -1
			}
			b += 1
			area := a * b
			// fmt.printfln("%v, %v, %i", p1, p2, area)
			// fmt.printfln("p1=%v, p2=%v, a=%i, b=%i, area=%i", p1, p2, a, b, area)
			top := p1.y < p2.y ? p1.y : p2.y
			bottom := p1.y > p2.y ? p1.y : p2.y
			left := p1.x < p2.x ? p1.x : p2.x
			right := p1.x > p2.x ? p1.x : p2.x

			append(&rects, Rectangle{i, j, p1, p2, top, bottom, left, right, area})
		}
	}

	rects_slice := rects[:]

	lines: [dynamic]Line
	for i in 0 ..< num_points {
		p1 := points[i]
		p2 := i + 1 == num_points ? points[0] : points[i + 1]
		append(&lines, Line{p1, p2})
	}

	fmt.printfln("num_lines: %i", len(lines))

	sort.quick_sort_proc(
		rects_slice,
		proc(r1: Rectangle, r2: Rectangle) -> int {return r2.area - r1.area},
	)

	rects: for r in rects_slice {
		fmt.printfln("%v", r)
		for l in lines {
			tl := Point{r.l, r.t}
			tr := Point{r.r, r.t}
			br := Point{r.r, r.b}
			bl := Point{r.l, r.b}

			// vertical
			if is_point_in_rect(l.p1, r) || is_point_in_rect(l.p2, r) {
				continue rects
			}
			if line_slices_rect(l, r) {
				continue rects
			}
			// fmt.printfln("%v", l)
		}
		break
	}

	// fmt.printfln("%v", rects_slice)
}

is_point_in_rect :: proc(p: Point, r: Rectangle) -> bool {
	return p.y > r.t && p.y < r.b && p.x > r.l && p.x < r.r
}

line_slices_rect :: proc(l: Line, r: Rectangle) -> bool {
	// horizontal
	left := l.p1.x < l.p2.x ? l.p1 : l.p2
	right := left == l.p1 ? l.p2 : l.p1

	if right.x <= r.l || left.x >= r.r {
		// fmt.printfln("h %v \n%v", l, r)
		return false
	}

	// vertically
	top := l.p1.y < l.p2.y ? l.p1 : l.p2
	bottom := top == l.p1 ? l.p2 : l.p1

	if bottom.y <= r.t || top.y >= r.b {
		// fmt.printfln("v %v \n%v", l, r)
		return false
	}

	return true
}

Line :: struct {
	p1, p2: Point,
}

Rectangle :: struct {
	i1, i2:     int,
	p1, p2:     Point,
	t, b, l, r: int,
	area:       int,
}

run_01 :: proc(points: []Point) {
	num_points := len(points)

	max_area := 0

	for i in 0 ..< num_points - 1 {
		for j in i + 1 ..< num_points {
			p1 := points[i]
			p2 := points[j]

			// fmt.printfln("%v, %v", p1, p2)


			a := p2.x - p1.x
			if a < 0 {
				a *= -1
			}
			a += 1
			b := p2.y - p1.y
			if b < 0 {
				b *= -1
			}
			b += 1
			area := a * b
			// fmt.printfln("%v, %v, %i", p1, p2, area)
			fmt.printfln("p1=%v, p2=%v, a=%i, b=%i, area=%i", p1, p2, a, b, area)

			if area > max_area {
				max_area = area
			}
		}
	}

	fmt.printfln("%i", max_area)

}

Point :: struct {
	x, y: int,
}
