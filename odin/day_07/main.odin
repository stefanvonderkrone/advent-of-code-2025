package main

import "../iterator"
import "core:bufio"
import "core:fmt"
import "core:io"
import "core:math"
import "core:os"
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

	prev_line := []u8{}
	sum := 0

	manifold: [dynamic][]u8

	for {
		str, ok := iterator.iterator_read(&it, '\n')

		if !ok {
			break
		}

		line := transmute([]u8)(str)
		append(&manifold, line)
	}

	cache := map[Coords]int{}

	start := 0
	first_line := manifold[0]
	for x in 0 ..< len(first_line) {
		if first_line[x] == 'S' {
			start = x
			break
		}
	}

	sum = 1 + walk_beam(&manifold, start, 1, &cache)

	fmt.printfln("%i", sum)

}

walk_beam_cached :: proc(manifold: ^[dynamic][]u8, x, y: int, cache: ^map[Coords]int) -> int {
	coords := Coords{x, y}
	timelines, ok := cache[coords]
	if ok {
		return timelines
	}
	timelines = walk_beam(manifold, x, y, cache)
	cache[coords] = timelines
	return timelines
}

walk_beam :: proc(manifold: ^[dynamic][]u8, x, y: int, cache: ^map[Coords]int) -> int {
	char := manifold[y][x]

	if len(manifold) == y + 1 {
		return 0
	}

	if char == '.' {
		return walk_beam_cached(manifold, x, y + 1, cache)
	}

	if char == '^' {
		return(
			1 +
			walk_beam_cached(manifold, x - 1, y + 1, cache) +
			walk_beam_cached(manifold, x + 1, y + 1, cache) \
		)
	}

	return 0
}

Coords :: struct {
	x, y: int,
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

	prev_line := []u8{}
	sum := 0

	for {
		str, ok := iterator.iterator_read(&it, '\n')

		if !ok {
			break
		}

		line := transmute([]u8)(str)

		if len(prev_line) == 0 {
			fmt.printfln("%s", line)
		}

		if len(prev_line) != 0 {
			// fmt.printfln("%s", prev_line)

			sum_splits := 0
			for x in 0 ..< len(prev_line) {
				prev_char := prev_line[x]
				char := line[x]

				if prev_char == 'S' {
					line[x] = '|'
				}

				if prev_char == '|' {
					if char == '^' {
						line[x - 1] = '|'
						line[x + 1] = '|'
						sum_splits += 1
					} else {
						line[x] = '|'
					}
				}

			}

			fmt.printfln("%s %i", line, sum_splits)
			sum += sum_splits
		}

		prev_line = line
	}

	fmt.printfln("%i", sum)
}
