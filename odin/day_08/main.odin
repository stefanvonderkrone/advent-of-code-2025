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
	run_02()
}

run_02 :: proc() {
	filename :: INPUT_01
	file_handle, err_handle := os.open(filename)
	if err_handle != nil {
		fmt.eprintln(err_handle)

	}
	defer os.close(file_handle)

	stream := os.stream_from_handle(file_handle)
	it: iterator.Iterator
	iterator.iterator_init(&it, &stream)

	boxes: [dynamic][3]f32

	for {
		str, ok := iterator.iterator_read(&it, '\n')

		if !ok {
			break
		}

		values := strings.split(str, ",")
		x, _ := strconv.parse_f32(values[0])
		y, _ := strconv.parse_f32(values[1])
		z, _ := strconv.parse_f32(values[2])

		append(&boxes, [3]f32{x, y, z})

	}

	// for box in boxes {
	// 	fmt.printfln("%v", box)
	// }

	distances: [dynamic]Distance
	num_boxes := len(boxes)

	for i in 0 ..< num_boxes - 1 {
		box1 := boxes[i]
		for j in (i + 1) ..< num_boxes {
			box2 := boxes[j]
			// if box1 == box2 {
			// 	continue
			// }

			distance := linalg.distance(box1, box2)

			append(&distances, Distance{box1, box2, distance})
		}
	}

	distances_slice := distances[:]

	sort.quick_sort_proc(distances_slice, proc(d1: Distance, d2: Distance) -> int {
		if d1.distance < d2.distance {
			return -1
		}
		return 1
	})

	// for distance in distances_slice[:] {
	// 	fmt.printfln("%v", distance)
	// }

	circuits_array: [dynamic]Circuit
	circuits := map[[3]f32]Circuit{}
	for box in boxes {
		boxes := new([dynamic][3]f32)
		append(boxes, box)
		circuit := Circuit{boxes}
		circuits[box] = circuit
		append(&circuits_array, circuit)
	}

	distance_loop: for distance in distances_slice[:] {
		c1, _ := circuits[distance.box1]
		c2, _ := circuits[distance.box2]

		if c1 == c2 {
			// do nothing
			continue
		}

		if c1 != c2 {
			for b in c2.boxes {
				append(c1.boxes, b)
				circuits[b] = c1
				i := index_of(circuits_array[:], c2)
				if i >= 0 {
					unordered_remove(&circuits_array, i)
				}
			}
			if len(circuits_array) == 1 {
				fmt.printfln("%v", distance)
				fmt.printfln("%i, %i", len(c1.boxes), len(boxes))
				fmt.printfln("%i", i64(distance.box1.x) * i64(distance.box2.x))
			}
		}
	}
}

run_01 :: proc() {
	filename :: INPUT_01
	file_handle, err_handle := os.open(filename)
	if err_handle != nil {
		fmt.eprintln(err_handle)

	}
	defer os.close(file_handle)

	stream := os.stream_from_handle(file_handle)
	it: iterator.Iterator
	iterator.iterator_init(&it, &stream)

	boxes: [dynamic][3]f32

	for {
		str, ok := iterator.iterator_read(&it, '\n')

		if !ok {
			break
		}

		values := strings.split(str, ",")
		x, _ := strconv.parse_f32(values[0])
		y, _ := strconv.parse_f32(values[1])
		z, _ := strconv.parse_f32(values[2])

		append(&boxes, [3]f32{x, y, z})

	}

	// for box in boxes {
	// 	fmt.printfln("%v", box)
	// }

	distances: [dynamic]Distance
	num_boxes := len(boxes)

	for i in 0 ..< num_boxes - 1 {
		box1 := boxes[i]
		for j in (i + 1) ..< num_boxes {
			box2 := boxes[j]
			// if box1 == box2 {
			// 	continue
			// }

			distance := linalg.distance(box1, box2)

			append(&distances, Distance{box1, box2, distance})
		}
	}

	distances_slice := distances[:]

	sort.quick_sort_proc(distances_slice, proc(d1: Distance, d2: Distance) -> int {
		if d1.distance < d2.distance {
			return -1
		}
		return 1
	})

	// for distance in distances_slice[:] {
	// 	fmt.printfln("%v", distance)
	// }

	circuits_array: [dynamic]Circuit
	circuits := map[[3]f32]Circuit{}
	for box in boxes {
		boxes := new([dynamic][3]f32)
		append(boxes, box)
		circuit := Circuit{boxes}
		circuits[box] = circuit
		append(&circuits_array, circuit)
	}

	for distance in distances_slice[:1000] {
		c1, _ := circuits[distance.box1]
		c2, _ := circuits[distance.box2]

		if c1 == c2 {
			// do nothing
			continue
		}

		if c1 != c2 {
			for b in c2.boxes {
				append(c1.boxes, b)
				circuits[b] = c1
				i := index_of(circuits_array[:], c2)
				if i >= 0 {
					unordered_remove(&circuits_array, i)
				}
			}
		}

	}

	circuits_slice := circuits_array[:]
	sort.quick_sort_proc(circuits_slice, proc(c1: Circuit, c2: Circuit) -> int {
		if len(c1.boxes) > len(c2.boxes) {
			return -1
		}
		return 1
	})

	f := 1
	for circuit in circuits_slice[:3] {
		fmt.printfln("%i, %v", len(circuit.boxes), circuit)
		f *= len(circuit.boxes)
	}

	fmt.printfln("%i", f)
}

index_of :: proc(list: $A/[]$T, el: T) -> int {
	for i in 0 ..< len(list) {
		e := list[i]
		if e == el {
			return i
		}
	}
	return -1
}

Circuit :: struct {
	boxes: ^[dynamic][3]f32,
}

Distance :: struct {
	box1:     [3]f32,
	box2:     [3]f32,
	distance: f32,
}
