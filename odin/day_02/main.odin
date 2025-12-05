package main

import "core:bufio"
import "core:container/small_array"
import "core:fmt"
import "core:io"
import "core:os"
import "core:slice"
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
	it: Iterator
	iterator_init(&it, &stream)

	count := 0
	occurrences := make([dynamic]int, 0, 1024)

	for {
		str, ok := iterator_read(&it, ',')
		count += count_pattern_mult(str, &occurrences)
		if !ok {
			break
		}
	}

	sliced := occurrences[:]
	sliced = slice.unique(sliced)

	fmt.printfln("count: %i", count)
	// fmt.printfln("array: %v", occurrences)

	sum := 0
	for s in sliced {
		sum += s
	}

	fmt.printfln("%i", sum)
}

count_pattern_mult :: proc(str: string, array: ^[dynamic]int) -> int {
	fmt.printfln("checking pattern: %s", str)
	split, err := strings.split(str, "-")
	if err != nil {
		fmt.eprintln(err)
		return 0
	}

	length := len(split)
	if length == 0 {
		return 0
	}

	start, ok_start := strconv.parse_int(split[0])
	if !ok_start {
		return 0
	}

	end: int = ---
	if length == 1 {
		end = start
	} else {
		n, ok_n := strconv.parse_int(split[1])
		if !ok_n {
			return 0
		}
		end = n
	}

	count := 0
	for i in start ..= end {
		str_i := fmt.aprint(i)
		str_len := len(str_i)
		str_len2 := str_len / 2

		for chunk_len in 1 ..= str_len2 {
			if str_len % chunk_len != 0 {
				continue
			}

			chunk := str_i[:chunk_len]
			num_chunks := str_len / chunk_len

			test_count := 0
			for j in 1 ..< num_chunks {
				test_pos := chunk_len * j
				test_chunk := str_i[test_pos:test_pos + chunk_len]

				// fmt.printfln("chunk: %s, test_chunk: %s", chunk, test_chunk)

				if test_chunk == chunk {
					test_count += 1
				}
			}

			// fmt.printfln("num_chunks: %i, test_count: %i", num_chunks, test_count)

			if test_count == num_chunks - 1 {
				count += 1
				append(array, i)
			}
		}
	}

	// fmt.printfln("str: %s, count %i", str, count)

	return count
}

count_pattern_2 :: proc(str: string, array: ^[dynamic]int) -> int {
	fmt.printfln("checking pattern: %s", str)
	split, err := strings.split(str, "-")
	if err != nil {
		fmt.eprintln(err)
		return 0
	}

	length := len(split)
	if length == 0 {
		return 0
	}

	start, ok_start := strconv.parse_int(split[0])
	if !ok_start {
		return 0
	}

	end: int = ---
	if length == 1 {
		end = start
	} else {
		n, ok_n := strconv.parse_int(split[1])
		if !ok_n {
			return 0
		}
		end = n
	}

	count := 0
	for i in start ..= end {
		str_i := fmt.aprint(i)
		str_len := len(str_i)
		str_len2 := str_len / 2

		if str_len % 2 != 0 {
			continue
		}

		chunk := str_i[:str_len2]
		test_chunk := str_i[str_len2:]

		if chunk == test_chunk {
			count += 1
			append(array, i)
		}
	}

	// fmt.printfln("str: %s, count %i", str, count)

	return count
}

Iterator :: struct {
	stream: ^io.Stream,
	reader: ^bufio.Reader,
	error:  io.Error,
}

iterator_init :: proc(it: ^Iterator, stream: ^io.Stream) {
	it.stream = stream
	reader := new(bufio.Reader)
	it.reader = reader
	bufio.reader_init(it.reader, stream^)
}

iterator_read :: proc(it: ^Iterator, delimiter: u8) -> (string, bool) {
	str, err := bufio.reader_read_string(it.reader, delimiter)
	if err == .EOF {
		return str[:len(str) - 1], false
	}
	if err != nil {
		it.error = err
		return str[:len(str) - 1], false
	}
	return str[:len(str) - 1], true
}
