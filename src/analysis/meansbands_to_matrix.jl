"""
meansbands_to_matrix(m, input_type, cond_type, output_vars;
    forecast_string = "", verbose = :low)

Reformat `MeansBands` object into matrices, and save to individual files.

### Inputs

- `m::AbstractModel`: model object
- `input_type::Symbol`: same as input into `forecast_one`
- `cond_type::Symbol`: same as input into `forecast_one`
- `output_vars::Symbol`: same as input into `forecast_one`

### Keyword Arguments

- `forecast_string::String`: identifies the forecast (if
  desired). Required if `input_type == :subset`
- `verbose::Symbol`: desired frequency of function progress messages printed to
  standard out. One of `:none`, `:low`, or `:high`
"""
function meansbands_to_matrix(m::AbstractModel, input_type::Symbol,
                              cond_type::Symbol, output_vars::Vector{Symbol};
                              forecast_string::String = "", verbose::Symbol = :low)

    # Determine full set of output_vars necessary for plotting desired results
    output_vars = add_requisite_output_vars(output_vars)
    output_dir  = workpath(m, "forecast")

    if VERBOSITY[verbose] >= VERBOSITY[:low]
        println()
        info("Converting means and bands to matrices for input_type = $input_type, cond_type = $cond_type...")
        println("Start time: $(now())")
        println("Means and bands matrices will be saved in $output_dir")
    end

    for output_var in output_vars
        meansbands_to_matrix(m, input_type, cond_type, output_var;
                             forecast_string = forecast_string, verbose = verbose)
    end

    if VERBOSITY[verbose] >= VERBOSITY[:low]
        println("\nConversion of means and bands complete: $(now())")
    end
end

function meansbands_to_matrix(m::AbstractModel, input_type::Symbol,
                              cond_type::Symbol, output_var::Symbol;
                              forecast_string::String = "", verbose::Symbol = :low)

    mb = read_mb(m, input_type, cond_type, output_var,
                 forecast_string = forecast_string)

    prod     = get_product(mb)   # history? forecast? shockdec?
    cl       = get_class(mb)     # pseudo? obs? state?
    condtype = get_cond_type(mb)

    ## Get name of file to write
    outfile = get_forecast_filename(m, input_type, cond_type,
                                    Symbol("mb_matrix_", output_var);
                                    pathfcn = workpath,
                                    forecast_string = forecast_string,
                                    fileformat = :h5)

    # Convert MeansBands objects to matrices
    means, bands = meansbands_to_matrix(mb)

    # Save to file
    h5open(outfile, "w") do file
        write(file, "means", means)
        write(file, "bands", bands)
    end

    if VERBOSITY[verbose] >= VERBOSITY[:high]
        println(" * Wrote $(basename(outfile))")
    end
end

"""
```
meansbands_to_matrix(mb::MeansBands)
```

Convert a `MeansBands` object to matrix form.
"""
function meansbands_to_matrix(mb::MeansBands)

    # extract useful info
    vars       = get_vars_means(mb)             # get names of variables
    nvars      = length(vars)                   # get number of variables

    tmp        = setdiff(names(mb.means), [:date])[1]
    T          = eltype(mb.means[tmp])          # type of elements of mb structure

    nperiods   = n_periods_means(mb)            # get number of periods
    prod       = get_product(mb)                # history? forecast? shockdec?
    inds       = mb.metadata[:indices]          # mapping from names of vars to indices
    bands_list = which_density_bands(mb)        # which bands are stored
    nbands     = length(bands_list)             # how many bands are stored

    # extract  matrices from MeansBands structure
    if prod in [:hist, :histut, :hist4q, :forecast, :forecastut, :forecast4q,
                :bddforecast, :bddforecastut, :bddforecast4q,
                :dettrend, :trend]

        # construct means and bands arrays
        means = Array{T,2}(nvars, nperiods)
        bands = Array{T}(nbands, nvars, nperiods)

        # extract each series and place in arrays
        for series in setdiff(names(mb.means), [:date])
            ind = inds[series]
            means[ind,:] = convert(Array{T},mb.means[series])

            for (i,band) in enumerate(bands_list)  # these are ordered properly already
                bands[i,ind,:] = convert(Array{T},mb.bands[series][Symbol(band)])
            end
        end

    elseif prod in [:shockdec, :irf]

        shock_inds = mb.metadata[:shock_indices]
        nshocks = length(shock_inds)

        # construct means and bands arrays
        means = Array{T}(nvars, nperiods, nshocks)
        bands = Array{T}(nbands, nvars, nperiods, nshocks)

        for series in setdiff(names(mb.means), [:date])

            var, shock = DSGE.parse_mb_colname(series)
            ind = inds[var]

            shock_ind = shock_inds[shock]
            means[ind,:,shock_ind] = convert(Array{T}, mb.means[series])

            for (band_ind, band) in enumerate(bands_list)
                bands[band_ind, ind, :, shock_ind] =
                    convert(Array{T}, mb.bands[series][Symbol(band)])
            end
        end
    end

    # return matrix
    return means, bands
end

