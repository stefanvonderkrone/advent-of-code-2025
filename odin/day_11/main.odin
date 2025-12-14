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

INPUT_YOU :: "input_you.txt"
INPUT_SVR :: "input_svr.txt"
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

	devices: map[string]Device

	for {
		str, ok := iterator.iterator_read(&it, '\n')

		if !ok {
			break
		}

		device := parse_device(str)
		devices[device.name] = device
	}

	sum := 0
	fft_to_dac := count_paths("fft", "dac", &devices)
	if fft_to_dac > 0 {
		svr_to_fft := count_paths("svr", "fft", &devices)
		dac_to_out := count_paths("dac", "out", &devices)
		sum = svr_to_fft * fft_to_dac * dac_to_out
		fmt.printfln(
			"svr_to_fft: %i, fft_to_dac: %i, dac_to_out: %i",
			svr_to_fft,
			fft_to_dac,
			dac_to_out,
		)
	} else {
		svr_to_dac := count_paths("svr", "dac", &devices)
		dac_to_fft := count_paths("dac", "fft", &devices)
		fft_to_out := count_paths("fft", "out", &devices)
		sum = svr_to_dac * dac_to_fft * fft_to_out
	}

	fmt.printfln("sum: %i", sum)

}

Devices :: map[string]Device
Cache :: map[string]int

count_paths_recursive :: proc(from: string, to: string, devices: ^Devices, cache: ^Cache) -> int {
	start := devices[from]

	if from == to {
		return 1
	}

	count := 0
	for output in start.outputs {
		count += count_paths(output, to, devices)
	}

	return count
}

CACHE: Cache

count_paths :: proc(from: string, to: string, devices: ^Devices) -> int {
	key := fmt.aprintf("%s-%s", from, to)
	count, ok := CACHE[key]
	// if ok {
	// 	fmt.printfln("cache hit: %s", key)
	// }
	if !ok {
		// fmt.printfln("cache miss: %s", key)
		count = count_paths_recursive(from, to, devices, &CACHE)
		CACHE[key] = count
	}
	return count
}

count_paths_ :: proc(from: string, to: string, devices: ^Devices) -> int {
	start := devices[from]
	paths_to_walk: [dynamic]string
	for path in start.outputs {
		append(&paths_to_walk, path)
	}
	count := 0

	for len(paths_to_walk) > 0 {
		path := pop(&paths_to_walk)
		if path == to {
			count += 1
			continue
		}

		device := devices[path]
		for output in device.outputs {
			append(&paths_to_walk, output)
		}

	}

	return count

}

parse_device :: proc(str: string) -> Device {
	device: Device

	splits := strings.split(str, " ")
	name := splits[0][0:len(splits[0]) - 1]
	outputs := splits[1:]

	device.name = name
	device.outputs = outputs

	return device
}

Device :: struct {
	name:    string,
	outputs: []string,
}
