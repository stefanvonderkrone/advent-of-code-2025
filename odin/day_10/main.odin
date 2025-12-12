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
	filename :: INPUT_TEST
	file_handle, err_handle := os.open(filename)
	if err_handle != nil {
		fmt.eprintln(err_handle)

	}
	defer os.close(file_handle)

	stream := os.stream_from_handle(file_handle)
	it: iterator.Iterator
	iterator.iterator_init(&it, &stream)

	machines: [dynamic]Machine

	for {
		str, ok := iterator.iterator_read(&it, '\n')

		if !ok {
			break
		}

		fmt.printfln("%s", str)

		machine: Machine
		parse_machine(str, &machine)
		fmt.printfln("%v", machine)

		append(&machines, machine)
	}

	sum := 0
	for machine in machines {
		sum += calc_min_permutation_02(machine)
	}

	fmt.printfln("%i", sum)
}

/**
different approach:
+ count the numbers each button can be pressed until its first index limit is reached
+ iterate over counts and test
**/
calc_min_permutation_02 :: proc(machine: Machine) -> int {
	joltage := machine.joltage
	count := 1
	num_buttons := len(machine.buttons)

	fmt.printfln("machine: %v", joltage)

	// loop to count
	main: for {

		indices := 0
		max_indices := pow_int(num_buttons, count)
		cache: map[int][dynamic]int

		// loop over indices
		for {
			// work with indices
			btn_indices: [dynamic]int
			partition_index(indices, num_buttons, count, &btn_indices)

			current_joltage, ok := cache[indices - num_buttons]
			if !ok {
				current_joltage = {}
				for i in 0 ..< len(joltage) {
					append(&current_joltage, 0)
				}
			} else {

			}

			// loop over indexed buttons
			buttons: for btn_index in btn_indices {
				btn := machine.buttons[btn_index]

				// loop over each button index
				for i in btn {
					// if current_joltage[i] == joltage[i] {
					// 	count += 1
					// 	break buttons
					// }
					// if current_joltage[i] == joltage[i] {
					// 	count += 1
					// 	continue counter
					// }
					current_joltage[i] += 1
				}
			}

			if is_equal(current_joltage[:], joltage) {
				fmt.printfln("count: %i, %v == %v", count, current_joltage[:], joltage)
				return count
			}

			// increment indices
			indices += 1
			if indices == max_indices {
				count += 1
				continue main
			}
		}
	}

	return count
}

calc_min_permutation_01 :: proc(machine: Machine) -> int {
	target := transmute([]u8)(machine.target)
	count := 1
	num_buttons := len(machine.buttons)

	fmt.printfln("machine: %v", target)

	main: for {
		if count == 9 {
			break
		}

		indices := 0
		max_indices := pow_int(num_buttons, count)

		for {
			// work with indices
			btn_indices: [dynamic]int
			partition_index(indices, num_buttons, count, &btn_indices)

			current_target: [dynamic]u8
			for i in 0 ..< len(target) {
				append(&current_target, 46)
			}

			for btn_index in btn_indices {
				btn := machine.buttons[btn_index]
				for i in btn {
					current_target[i] = current_target[i] == 46 ? 35 : 46
				}
			}

			if is_equal(current_target[:], target) {
				// fmt.printfln("count: %i, %v == %v", count, current_target[:], target)
				return count
			}

			// increment indices
			indices += 1
			if indices == max_indices {
				count += 1
				continue main
			}
		}
	}

	return count
}

is_equal :: proc(a, b: $A/[]$T) -> bool {
	a_len := len(a)
	b_len := len(b)

	if a_len != b_len {
		return false
	}

	for i in 0 ..< a_len {
		if a[i] != b[i] {
			return false
		}
	}

	return true
}

partition_index :: proc(index, n, count: int, indices: ^[dynamic]int) {
	i := index
	for _ in 0 ..< count {
		ii := i % n
		append(indices, ii)
		i -= ii
		i /= n
	}
}

pow_int :: proc(x, power: int) -> int {
	f := x
	for i in 1 ..< power {
		f *= x
	}
	return f
}

parse_machine :: proc(str: string, machine: ^Machine) {
	splits := strings.split(str, " ")
	num_splits := len(splits)

	target := splits[0][1:len(splits[0]) - 1]
	machine.target = target

	buttons_slice := splits[1:num_splits - 1]
	num_buttons := len(buttons_slice)
	buttons := new([dynamic]Button)
	for i in 0 ..< num_buttons {
		btn := buttons_slice[i]
		btn = btn[1:len(btn) - 1]
		indices := strings.split(btn, ",")
		button := new([dynamic]int)
		for index in indices {
			x, _ := strconv.parse_int(index)
			append(button, x)
		}
		append(buttons, button[:])
	}

	machine.buttons = buttons[:]

	joltage := splits[num_splits - 1]
	joltage_slice := joltage[1:len(joltage) - 1]
	js: [dynamic]int
	for j in strings.split(joltage_slice, ",") {
		x, _ := strconv.parse_int(j)
		append(&js, x)
	}
	machine.joltage = js[:]
}

Button :: []int

Machine :: struct {
	target:  string,
	buttons: []Button,
	joltage: []int,
}
