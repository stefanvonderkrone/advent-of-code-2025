package math2

pow_10 :: proc(n: int) -> int {
	m := 1
	for i in 0 ..< n {
		m *= 10
	}
	return m
}
