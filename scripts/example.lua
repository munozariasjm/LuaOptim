simion.workbench_program()
local xcross = 134
local xcrosstotal = 395.5
local xlast = {}
local xlast_t = {}
local count = 0
local total_count = 0

local Vl1,Vl2

print('N       Nt     eta(%)    Vl1      Vl2')
function segment.initialize_run()
    -- Reset the counter before each rerun (only needed if Rerun is enabled).
    count = 0
    total_count = 0
    xlast = {}
    xlast_t = {}
  end
function segment.other_actions()
    if ((xlast_t[ion_number] or ion_px_mm) < xcrosstotal) == (ion_px_mm >= xcrosstotal) then
        total_count = total_count + 1
    end
    xlast_t[ion_number] = ion_px_mm

    if ((xlast[ion_number] or ion_px_mm) < xcross) == (ion_px_mm >= xcross) then
        if (ion_py_mm-139.95)^2 + (ion_pz_mm-139.51)^2 < (3.75)^2 then
            count = count + 1
        end
      end
      xlast[ion_number] = ion_px_mm
  end

-- called on end of each run...
function segment.terminate_run()
    local transmission = 100 * count / total_count
    if transmission - math.floor(transmission)<0.5 then
        transmission = math.floor(transmission)
    else
        transmission = math.ceil(transmission)
    end
    -- print(count,total_count,transmission,Vl1,Vl2)
    print(transmission)
end