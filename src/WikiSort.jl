module WikiSort

const DEFAULT_CACHE_SIZE = 512

immutable WikiSorter{T}
    cache::Vector{T}
    cache_size::Int
end

function call{T}(::Type{WikiSorter{T}}, cache_size::Integer=DEFAULT_CACHE_SIZE)
    return WikiSorter{T}(fill(zero(T), cache_size), cache_size)
end

function reverse!(arr::AbstractVector, r::UnitRange)
    for i = (div(length(r), 2) - 1):-1:0
        arr[r.start + i], arr[r.stop - i] = arr[r.stop - i], arr[r.start + i]
    end
end

function block_swap!(arr::AbstractVector, start_idx1::Integer, start_idx2::Integer, count::Integer)
    for i = 1:count
        # swap
        arr[start_idx1 + i], arr[start_idx2 + i] = arr[start_idx2 + i], arr[start_idx1 + i]
    end
end

# rotate the values in an array ([0 1 2 3] becomes [1 2 3 0] if we rotate by 1)
# this assumes that 0 <= amount <= length(r)
function rotate!{T}(s::WikiSorter{T}, arr::AbstractVector{T}, r::UnitRange, amount::Integer, use_cache=true)
    if length(r) == 0
        return
    end

    if amount >= 0
        split = r.start + amount
    else
        split = r.stop + amount + 1
    end

    range1 = r.start:(split - 1)
    range2 = split:r.stop

    if use_cache
        if length(range1) <= length(range2)
            if length(range1) <= s.cache_size
                # if cache not null
                # unsafe_copy!
                copy!(s.cache, 1, arr, range1.start, length(range1))
                copy!(arr, range1.start, arr, range2.start, length(range2))
                copy!(arr, range1.start + length(range2), s.cache, 1, length(range1))
                return
            end
        else
            if length(range2) <= s.cache_size
                # ditto
                copy!(s.cache, 1, arr, range2.start, length(range2))
                copy!(arr, range2.stop - length(range1) + 1, arr, range1.start, length(range1))
                copy!(arr, range1.start, s.cache, 1, length(range2))
                return
            end
        end
    end

    reverse!(arr, range1)
    reverse!(arr, range2)
    reverse!(arr, r)
    return
end

function rotate!(arr::AbstractVector, r::UnitRange, amount::Integer)
    Base.reverse!(arr, r.start, r.start + amount - 1)
    Base.reverse!(arr, r.start + amount, r.stop)
    Base.reverse!(arr, r.start, r.stop)
end

function binaryfirst(arr::AbstractVector, r::UnitRange, value)
    start = r.start
    stop = r.stop
    while start < stop
        mid = start + div(stop - start, 2)
        if arr[mid] < value
            start = mid + 1
        else
            stop = mid
        end
    end

    if start == r.stop && arr[start] < value
        start += 1
    end

    return start
end

function binarylast(arr::AbstractVector, r::UnitRange, value)
    start = r.start
    stop = r.stop
    while start < stop
        mid = start + div(stop - start, 2)
        if arr[mid] <= value
            start = mid + 1
        else
            stop = mid
        end
    end

    if start == r.stop && arr[start] <= value
        start += 1
    end

    return start
end

function insertion_sort!(arr::AbstractVector, r::UnitRange)
    for i = (r.start + 1):r.stop
        temp = arr[i]
        j = i
        while j > r.start && arr[j - 1] > temp
            arr[j] = arr[j - 1]
            j -= 1
        end
        arr[j] = temp
    end
end


end # module
