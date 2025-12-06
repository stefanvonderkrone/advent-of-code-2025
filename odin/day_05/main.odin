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
	filename :: INPUT_01
	file_handle, err_handle := os.open(filename)
	if err_handle != nil {
		fmt.eprintln(err_handle)

	}
	defer os.close(file_handle)

	stream := os.stream_from_handle(file_handle)
	it: iterator.Iterator
	iterator.iterator_init(&it, &stream)

	ranges: [dynamic]string
	for {
		str, ok := iterator.iterator_read(&it, '\n')

		if !ok || len(str) == 0 {
			break
		}

		append(&ranges, str)
	}

	ingredients: [dynamic]string
	for {
		str, ok := iterator.iterator_read(&it, '\n')

		if !ok || len(str) == 0 {
			break
		}

		append(&ingredients, str)
	}

	combined_ranges: [dynamic]Range
	generate: for range_str in ranges {
		splits := strings.split(range_str, "-")
		from, _ := strconv.parse_int(splits[0])
		to, _ := strconv.parse_int(splits[1])

		range := Range{from, to}

		for &r in combined_ranges {
			if range.start > r.end || range.end < r.start {
				continue
			}
			r.start = range.start < r.start ? range.start : r.start
			r.end = range.end > r.end ? range.end : r.end
			continue generate
		}

		append(&combined_ranges, range)
	}

	sum := 0
	for i in ingredients {
		n, _ := strconv.parse_int(i)
		for range in combined_ranges {
			if n >= range.start && n <= range.end {
				sum += 1
				break
			}
		}
	}

	// sort ranges
	ranges_slice := combined_ranges[:]
	sort.quick_sort_proc(
		ranges_slice,
		proc(r1: Range, r2: Range) -> int {return sort.compare_ints(r1.start, r2.start)},
	)
	// for range in ranges_slice {
	// 	fmt.printfln("%v", range)
	// }

	reduced_ranges := make([dynamic]Range, 0, len(ranges_slice))
	reduce: for range in ranges_slice {
		for &r in reduced_ranges {
			if range.start > r.end || range.end < r.start {
				continue
			}
			r.start = range.start < r.start ? range.start : r.start
			r.end = range.end > r.end ? range.end : r.end
			continue reduce
		}
		append(&reduced_ranges, Range{range.start, range.end})
	}

	fresh_sum := 0
	for range in reduced_ranges {
		fresh_sum += range.end - range.start + 1
	}

	fmt.printfln("sum: %i, len: %i, fresh_sum: %i", sum, len(reduced_ranges), fresh_sum)
	// print_lines(&ranges)
	// print_lines(&ingredients)
}

Range :: struct {
	start: int,
	end:   int,
}

print_lines :: proc(lines: ^[dynamic]string) {
	for line in lines {
		fmt.printfln("%s", line)
	}
}
