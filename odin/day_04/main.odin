package main

import "../iterator"
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
	it: iterator.Iterator
	iterator.iterator_init(&it, &stream)

	lines: [dynamic][]u8

	for {
		str, ok := iterator.iterator_read(&it, '\n')

		if !ok {
			break
		}

		line := transmute([]u8)(str)
		append(&lines, line)

	}

	run_02(&lines)
}

run_02 :: proc(lines: ^[dynamic][]u8) {
	num_lines := len(lines)
	neighbors: [dynamic]u8
	sum := 0

	for {
		num_x := 0
		for y in 0 ..< num_lines {
			line := lines[y]
			num_chars := len(line)

			for x in 0 ..< num_chars {
				char := line[x]

				if char == '@' {
					for yy in -1 ..= 1 {
						for xx in -1 ..= 1 {
							if xx == 0 && yy == 0 {
								continue
							}

							yyy := y + yy
							xxx := x + xx

							if yyy < 0 || yyy >= num_lines || xxx < 0 || xxx >= num_chars {
								continue
							}

							test_char := lines[yyy][xxx]

							if test_char == '@' || test_char == 'x' {
								append(&neighbors, lines[yyy][xxx])
							}
						}
					}

					num_rolls := len(neighbors)

					if num_rolls < 4 {
						num_x += 1
						line[x] = 'x'
					}

					clear(&neighbors)
				}
			}
		}

		sum += num_x

		if num_x == 0 {
			break
		}

		// clear x's
		for y in 0 ..< num_lines {
			line := lines[y]
			num_chars := len(line)
			for x in 0 ..< num_chars {
				if line[x] == 'x' {
					line[x] = '.'
				}
			}
		}
	}

	fmt.printfln("%i", sum)
	print_lines(lines)
}

run_01 :: proc(lines: ^[dynamic][]u8) {
	num_lines := len(lines)
	neighbors: [dynamic]u8
	num_x := 0
	for y in 0 ..< num_lines {
		line := lines[y]
		num_chars := len(line)

		for x in 0 ..< num_chars {
			char := line[x]

			if char == '@' {
				// test

				for yy in -1 ..= 1 {
					for xx in -1 ..= 1 {
						if xx == 0 && yy == 0 {
							continue
						}

						yyy := y + yy
						xxx := x + xx

						if yyy < 0 || yyy >= num_lines || xxx < 0 || xxx >= num_chars {
							continue
						}

						test_char := lines[yyy][xxx]

						if test_char == '@' || test_char == 'x' {
							append(&neighbors, lines[yyy][xxx])
						}
					}
				}

				num_rolls := len(neighbors)

				if num_rolls < 4 {
					num_x += 1
					line[x] = 'x'
				}

				clear(&neighbors)
			}
		}

	}

	fmt.printfln("%i", num_x)
	print_lines(lines)
}

print_lines :: proc(lines: ^[dynamic][]u8) {
	for line in lines {
		fmt.printfln("%s", line)
	}
}
