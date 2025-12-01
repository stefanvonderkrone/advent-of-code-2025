package main

import "core:bufio"
import "core:fmt"
import "core:os"
import "core:strconv"

main :: proc() {
	puzzle_01()
}


PUZZLE_FILE_TEST :: "input_test.txt"
PUZZLE_FILE_01 :: "input_01.txt"

puzzle_01 :: proc() {
	file_handle, err_handle := os.open(PUZZLE_FILE_01)
	if err_handle != nil {
		fmt.eprintln(err_handle)
	}
	defer os.close(file_handle)

	file_stats, err_stats := os.fstat(file_handle)
	if err_stats != nil {
		fmt.eprintln(err_stats)
	}

	reader: bufio.Reader
	stream := os.stream_from_handle(file_handle)
	bufio.reader_init(&reader, stream)

	start := 50
	num_zero := 0

	for {
		line, err := bufio.reader_read_string(&reader, '\n')
		if err == .EOF {
			break
		}
		if err != nil {
			panic(fmt.aprintfln("%v", err))
		}

		direction := line[:1]
		count, ok := strconv.parse_int(line[1:len(line) - 1])
		// fmt.printfln("direction: %s, count: %i", direction, count)

		for count >= 100 {
			count -= 100
			num_zero += 1
		}

		if direction == "L" && start > 0 && count > start {
			num_zero += 1
		}
		if direction == "R" && count > 100 - start {
			num_zero += 1
		}

		if (direction == "L") {
			start -= count
		} else {
			start += count
		}

		if start >= 100 {
			start -= 100
		}
		if start < 0 {
			start += 100
		}

		if start == 0 {
			num_zero += 1
		}

		fmt.printfln(
			"direction: %s, count: %i, start: %i, num_zero: %i",
			direction,
			count,
			start,
			num_zero,
		)
	}

	fmt.printfln("%i", ((-1 * -244 + 100) / 100) * 100)
	fmt.printfln("end: %i, num_zero: %i", start, num_zero)
}
