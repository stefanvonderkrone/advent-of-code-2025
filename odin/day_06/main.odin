package main

import "core:bufio"
import "core:fmt"
import "core:io"
import "core:math"
import "core:os"
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
	it: Iterator
	iterator_init(&it, &stream)

	lines: [dynamic]string

	for {
		str, ok := iterator_read(&it, '\n')

		if !ok {
			break
		}

		// fmt.printfln("line: %v", line)
		append(&lines, str)

	}

	num_lines := len(lines) - 1
	last_line := lines[num_lines]

	char_index := 0
	cols: [dynamic]^Column
	current_col: ^Column
	for char in last_line {
		if char == '+' || char == '*' {
			if current_col != nil {
				current_col.width -= 1
			}
			col := new(Column)
			col.operator = char
			col.start = char_index
			current_col = col
			append(&cols, col)
		}
		current_col.width += 1
		char_index += 1
	}
	// current_col.width += 1

	sum := 0
	for col in cols {
		col_lines := new([dynamic]string)

		for i in 0 ..< num_lines {
			line := lines[i]
			append(col_lines, line[col.start:col.start + col.width])
		}

		col.lines = col_lines

		sum += calc_col(col)
	}
	fmt.printfln("%i", sum)
}

Column :: struct {
	operator: rune,
	width:    int,
	start:    int,
	lines:    ^[dynamic]string,
}

calc_col :: proc(col: ^Column) -> int {
	xs: [dynamic]int
	for i in 0 ..< col.width {
		ii := col.width - i - 1

		m := 0
		line_index := 0
		num_lines := len(col.lines)
		numbers: [dynamic]int
		for line in col.lines {
			n, ok := strconv.parse_int(line[ii:ii + 1])
			if ok {
				append(&numbers, n)
			}
			line_index += 1
		}
		num_numbers := len(numbers)
		for n, index in numbers {
			m += pow_10(num_numbers - index - 1) * n
		}
		// fmt.printfln("%i", m)
		// fmt.printfln("%i, %s, %v", ii, col.lines[0][ii:ii + 1], col.lines[0])
		append(&xs, m)
	}

	if col.operator == '*' {
		f := 1
		for n in xs {
			f *= n
		}
		return f
	}
	sum := 0
	for n in xs {
		sum += n
	}
	return sum
}

pow_10 :: proc(n: int) -> int {
	m := 1
	for i in 0 ..< n {
		m *= 10
	}
	return m
}

run_01 :: proc() {
	filename :: INPUT_01
	file_handle, err_handle := os.open(filename)
	if err_handle != nil {
		fmt.eprintln(err_handle)

	}
	defer os.close(file_handle)

	stream := os.stream_from_handle(file_handle)
	it: Iterator
	iterator_init(&it, &stream)

	lines: [dynamic][dynamic]string

	for {
		str, ok := iterator_read(&it, '\n')

		if !ok {
			break
		}

		line: [dynamic]string
		get_line(str, &line)
		// fmt.printfln("line: %v", line)
		append(&lines, line)

	}

	columns: [dynamic][dynamic]string
	num_lines := len(lines)
	last_line := lines[num_lines - 1]
	i := 0
	for part in last_line {
		col: [dynamic]string

		j := 0
		for line in lines {
			// skip last line
			if j == num_lines - 1 {
				break
			}
			if len(line) > i {
				append(&col, line[i])
			}
			j += 1
		}
		append(&columns, col)
		i += 1

		// fmt.printfln("col: %v", col)
	}

	sum := 0
	numbers := make([dynamic]int, len(columns))
	col_index := 0
	for operator in last_line {
		col := columns[col_index]
		if operator == "+" {
			sum += add_col(&col)
		}
		if operator == "*" {
			sum += mult_col(&col)
		}
		col_index += 1
	}

	fmt.printfln("%i", sum)
}

add_col :: proc(col: ^[dynamic]string) -> int {
	sum := 0
	for s in col {
		n, ok := strconv.parse_int(s)
		if ok {
			sum += n
		}
	}
	return sum
}

mult_col :: proc(col: ^[dynamic]string) -> int {
	f := 1
	for s in col {
		n, ok := strconv.parse_int(s)
		if ok {
			f *= n
		}
	}
	return f
}

get_line :: proc(line: string, array: ^[dynamic]string) {
	parts := strings.split(line, " ")
	for part in parts {
		if part != "" {
			append(array, part)
		}
	}
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
