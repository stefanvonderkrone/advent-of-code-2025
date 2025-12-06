package iterator

import "core:bufio"
import "core:io"

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
