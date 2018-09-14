__precompile__(true)

module StateSpaceReconstruction

using Reexport
using DynamicalSystemsBase
using DynamicalSystems
using StaticArrays
using Simplices.even_sampling_rules
include("embedding/delaunay_colwise.jl") # include before embedding
include("embedding/embedding_colwise.jl")


####################################
# Triangulation
####################################
function delaunaytriang(E::AbstractEmbedding; noise_factor = 0.01)
    if size(unique(E.points, 2), 2) < size(E.points, 2)
      warn("""Embedding points not unique. Adding uniformly distributed noise
            to each observation equal to $noise_factor times the maximum of the
            standard deviations for each variable).""")
      # Find standard deviation along each axis
      max_std = maximum(std(E3.points, 2))
      σ = noise_factor*max_std
      pts = E.points .* rand(Uniform(-σ, σ))

      #Python expects row-major, so we need to transpose
      triang = delaunay(transpose(pts))
      return DelaunayTriangulation(hcat(triang...))
   end
    # Python expects row-major, so we need to transpose
    triang = delaunay(transpose(E.points))
    return DelaunayTriangulation(hcat(triang...))
end
include("partitioning/Partitioning.jl")
include("embedding/invariantize_colwise.jl")
include("partitioning/simplexpartition.jl")

export delaunaytriang
end # module
