import sys


def parse_input ():
    return [l for l in sys.stdin]


def max_column_width (line_words, ):
    return max([ len(line[0]) for line in line_words])


def transpose (array):
    N = len(array)
    M = len(array[0])

    new_array = []

    for j in range(M):
        row = []
        for i in range(N):
            row.append(array[i][j])
        new_array.append(row)

    return new_array


def justify (w, length):
    if w.isdigit():
        return w.rjust(length)
    else:
        return w.ljust(length)


def main(separator='\t', col_width=8):
    lines = parse_input()
    line_words = [[w.strip() for w in line.split(separator)] for line in lines]
    column_widths = [[len(w) for w in line] for line in line_words]
    max_column_width = [max(c) for c in transpose(column_widths)]
    justified_line_words = [[justify(w,max_column_width[i]) for i, w in enumerate(line)] for line in line_words]

    rows = [(col_width*" ").join(jlw).strip() for jlw in justified_line_words]

    # for r in rows:
    #     print(r)

    print("\n".join(rows))
    # return "\r".join(rows)


if __name__ == '__main__':
    args = sys.argv[1:]
    options = {k: v for k,v in [a.split("=") for a in args]}
    main(**options)
