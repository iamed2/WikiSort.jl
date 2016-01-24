using WikiSort
if VERSION < v"0.5-"
    using BaseTestNext
else
    using Base.Test
end


@testset "Reverse" begin
    @testset "Whole array" begin
        reverse_tests = [
            (Int[], Int[]),
            ([1], [1]),
            ([1, 2], [2, 1]),
            ([1, 2, 3], [3, 2, 1]),
            (collect(1:1000), collect(1000:-1:1)),
        ]

        @testset "Base" for (fwd, rev) in reverse_tests
            fwd = copy(fwd)
            Base.reverse!(fwd, 1, length(fwd))
            @test fwd == rev
        end

        @testset "WikiSort" for (fwd, rev) in reverse_tests
            fwd = copy(fwd)
            WikiSort.reverse!(fwd, 1:length(fwd))
            @test fwd == rev
        end
    end

    @testset "Partial reverse" begin
        fwd = [1, 2, 3, 4, 5, 6, 7, 8, 9]
        reverse_tests = [
            (1:0, fwd),
            (1:1, fwd),
            (5:4, fwd),
            (5:5, fwd),
            (9:8, fwd),
            (9:9, fwd),
            (1:2, [2, 1, 3, 4, 5, 6, 7, 8, 9]),
            (1:3, [3, 2, 1, 4, 5, 6, 7, 8, 9]),
            (4:6, [1, 2, 3, 6, 5, 4, 7, 8, 9]),
            (5:9, [1, 2, 3, 4, 9, 8, 7, 6, 5]),
        ]

        @testset "Base" for (rng, rev) in reverse_tests
            fwd_copy = copy(fwd)
            Base.reverse!(fwd_copy, rng.start, rng.stop)
            @test fwd_copy == rev
        end

        @testset "WikiSort" for (rng, rev) in reverse_tests
            fwd_copy = copy(fwd)
            WikiSort.reverse!(fwd_copy, rng)
            @test fwd_copy == rev
        end
    end
end

@testset "Rotate" begin
    ws = WikiSort.WikiSorter{Int}()

    @testset "Full rotation" begin
        @testset "Full array" begin
            rotation_tests = [
                (Int[], Int[]),
                ([1], [1]),
                ([2, 3], [2, 3]),
                (collect(1:10), collect(1:10)),
            ]

            @testset "Forward" begin
                @testset "No cache" for (orig, rotd) in rotation_tests
                    orig_copy = copy(orig)
                    amt = length(orig_copy)
                    WikiSort.rotate!(ws, orig_copy, 1:amt, amt, false)
                    @test orig_copy == rotd
                end

                @testset "Cache" for (orig, rotd) in rotation_tests
                    orig_copy = copy(orig)
                    amt = length(orig_copy)
                    WikiSort.rotate!(ws, orig_copy, 1:amt, amt, true)
                    @test orig_copy == rotd
                end
            end

            @testset "Reverse" begin
                @testset "No cache" for (orig, rotd) in rotation_tests
                    orig_copy = copy(orig)
                    amt = length(orig_copy)
                    WikiSort.rotate!(ws, orig_copy, 1:amt, -amt, false)
                    @test orig_copy == rotd
                end

                @testset "Cache" for (orig, rotd) in rotation_tests
                    orig_copy = copy(orig)
                    amt = length(orig_copy)
                    WikiSort.rotate!(ws, orig_copy, 1:amt, -amt, true)
                    @test orig_copy == rotd
                end
            end
        end

        @testset "Partial array" begin
            arr = collect(1:10)

            rotation_tests = [
                ([1], 1:0, [1]),
                ([1], 2:1, [1]),
                ([2, 3], 1:1, [2, 3]),
                ([2, 3], 2:2, [2, 3]),
                (arr, 1:9, arr),
                (arr, 5:9, arr),
                (arr, 8:9, arr),
                (arr, 2:10, arr),
                (arr, 7:10, arr),
                (arr, 9:10, arr),
            ]

            @testset "Forward" begin
                @testset "No cache" for (orig, rng, rotd) in rotation_tests
                    orig_copy = copy(orig)
                    amt = length(rng)
                    WikiSort.rotate!(ws, orig_copy, rng, amt, false)
                    @test orig_copy == rotd
                end

                @testset "Cache" for (orig, rng, rotd) in rotation_tests
                    orig_copy = copy(orig)
                    amt = length(rng)
                    WikiSort.rotate!(ws, orig_copy, rng, amt, true)
                    @test orig_copy == rotd
                end
            end

            @testset "Reverse" begin
                @testset "No cache" for (orig, rng, rotd) in rotation_tests
                    orig_copy = copy(orig)
                    amt = length(rng)
                    WikiSort.rotate!(ws, orig_copy, rng, -amt, false)
                    @test orig_copy == rotd
                end

                @testset "Cache" for (orig, rng, rotd) in rotation_tests
                    orig_copy = copy(orig)
                    amt = length(rng)
                    WikiSort.rotate!(ws, orig_copy, rng, -amt, true)
                    @test orig_copy == rotd
                end
            end
        end
    end

    @testset "Partial rotation" begin
        @testset "Full array" begin
            @testset "Forward" begin
                rotation_tests = [
                    ([2, 3], 1, [3, 2]),
                    ([1, 2, 3], 1, [2, 3, 1]),
                    ([1, 2, 3], 2, [3, 1, 2]),
                ]

                @testset "No cache" for (orig, amt, rotd) in rotation_tests
                    orig_copy = copy(orig)
                    WikiSort.rotate!(ws, orig_copy, 1:length(orig_copy), amt, false)
                    @test orig_copy == rotd
                end

                @testset "Cache" for (orig, amt, rotd) in rotation_tests
                    orig_copy = copy(orig)
                    WikiSort.rotate!(ws, orig_copy, 1:length(orig_copy), amt, true)
                    @test orig_copy == rotd
                end
            end

            @testset "Reverse" begin
                rotation_tests = [
                    ([2, 3], -1, [3, 2]),
                    ([1, 2, 3], -1, [3, 1, 2]),
                    ([1, 2, 3], -2, [2, 3, 1]),
                ]

                @testset "No cache" for (orig, amt, rotd) in rotation_tests
                    orig_copy = copy(orig)
                    WikiSort.rotate!(ws, orig_copy, 1:length(orig_copy), amt, false)
                    @test orig_copy == rotd
                end

                @testset "Cache" for (orig, amt, rotd) in rotation_tests
                    orig_copy = copy(orig)
                    WikiSort.rotate!(ws, orig_copy, 1:length(orig_copy), amt, true)
                    @test orig_copy == rotd
                end
            end
        end

        @testset "Partial array" begin
            arr = collect(1:10)

            @testset "Forward" begin
                rotation_tests = [
                    ([1, 2, 3, 4], 1:2, 1, [2, 1, 3, 4]),
                    ([1, 2, 3, 4], 2:3, 1, [1, 3, 2, 4]),
                    ([1, 2, 3, 4], 3:4, 1, [1, 2, 4, 3]),
                    ([1, 2, 3, 4], 1:3, 1, [2, 3, 1, 4]),
                    ([1, 2, 3, 4], 1:3, 2, [3, 1, 2, 4]),
                    ([1, 2, 3, 4], 2:4, 1, [1, 3, 4, 2]),
                    ([1, 2, 3, 4], 2:4, 2, [1, 4, 2, 3]),
                ]

                @testset "No cache" for (orig, rng, amt, rotd) in rotation_tests
                    orig_copy = copy(orig)
                    WikiSort.rotate!(ws, orig_copy, rng, amt, false)
                    @test orig_copy == rotd
                end

                @testset "Cache" for (orig, rng, amt, rotd) in rotation_tests
                    orig_copy = copy(orig)
                    WikiSort.rotate!(ws, orig_copy, rng, amt, true)
                    @test orig_copy == rotd
                end
            end

            @testset "Reverse" begin
                rotation_tests = [
                    ([1, 2, 3, 4], 1:2, -1, [2, 1, 3, 4]),
                    ([1, 2, 3, 4], 2:3, -1, [1, 3, 2, 4]),
                    ([1, 2, 3, 4], 3:4, -1, [1, 2, 4, 3]),
                    ([1, 2, 3, 4], 1:3, -1, [3, 1, 2, 4]),
                    ([1, 2, 3, 4], 1:3, -2, [2, 3, 1, 4]),
                    ([1, 2, 3, 4], 2:4, -1, [1, 4, 2, 3]),
                    ([1, 2, 3, 4], 2:4, -2, [1, 3, 4, 2]),
                ]

                @testset "No cache" for (orig, rng, amt, rotd) in rotation_tests
                    orig_copy = copy(orig)
                    WikiSort.rotate!(ws, orig_copy, rng, amt, false)
                    @test orig_copy == rotd
                end

                @testset "Cache" for (orig, rng, amt, rotd) in rotation_tests
                    orig_copy = copy(orig)
                    WikiSort.rotate!(ws, orig_copy, rng, amt, true)
                    @test orig_copy == rotd
                end
            end
        end
    end
end
