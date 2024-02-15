function obj(val)
    return {
        val=val or 0;
        add=function(a,b) return obj(a.val+b.val) end
    }
end

o1=obj(4)
o2=obj(7)
o3=o1:add(o2)
print(o1.val,o2.val,o3.val)