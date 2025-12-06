package main

import "core:bufio"
import "core:fmt"
import "core:io"
import "core:math"
import "core:os"
import "core:strconv"

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

	sum := 0

	for {
		str, ok := iterator_read(&it, '\n')

		if !ok {
			break
		}

		joltage := find_highest_joltage_12(str)
		sum += joltage

		// fmt.printfln("joltage: %i", joltage)
		// fmt.printfln("ok: %b", ok)
		// fmt.printfln("line: %s", str)
	}

	fmt.printfln("sum: %i", sum)
}

find_highest_joltage_12 :: proc(line: string) -> int {
	str_len := len(line)

	num := 0
	lastIndex := 0

	for i in 0 ..< 12 {
		n := 0
		for j in lastIndex ..< str_len - (11 - i) {
			char := line[j:j + 1]
			m, ok := strconv.parse_int(char)
			if ok && m > n {
				n = m
				lastIndex = j + 1
			}
		}
		// fmt.printfln("n: %i, num: %i", n, pow_10(11 - i) * n)
		num += pow_10(11 - i) * n
	}

	// fmt.printfln("n: %i", num)

	return num
}

pow_10 :: proc(n: int) -> int {
	m := 1
	for i in 0 ..< n {
		m *= 10
	}
	return m
}

find_highest_joltage :: proc(line: string) -> int {
	n := 0
	str_len := len(line)

	for i in 0 ..< str_len - 1 {
		ten, ten_ok := strconv.parse_int(line[i:i + 1])
		if !ten_ok {
			continue
		}
		ten *= 10
		for j in i + 1 ..< str_len {
			one, one_ok := strconv.parse_int(line[j:j + 1])
			if !one_ok {
				continue
			}
			m := ten + one
			if m > n {
				n = m
			}
		}
	}

	return n
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
	if len(str) == 0 {
		return str, false
	}
	if err == .EOF {
		return str[:len(str) - 1], false
	}
	if err != nil {
		it.error = err
		return str[:len(str) - 1], false
	}
	return str[:len(str) - 1], true
}
