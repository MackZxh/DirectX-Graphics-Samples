//*********************************************************
//
// Copyright (c) Microsoft. All rights reserved.
// This code is licensed under the MIT License (MIT).
// THIS CODE IS PROVIDED *AS IS* WITHOUT WARRANTY OF
// ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING ANY
// IMPLIED WARRANTIES OF FITNESS FOR A PARTICULAR
// PURPOSE, MERCHANTABILITY, OR NON-INFRINGEMENT.
//
//*********************************************************
#define HLSL
#include "ConstructAABBBindings.h"
#include "RayTracingHelper.hlsli"

BoundingBox ComputeLeafAABB(uint primitiveIndex, uint offsetToVertices, out uint2 flags)
{
    uint offsetToReadPrimitives = offsetToVertices + primitiveIndex * SizeOfPrimitive;
    uint primitiveType = outputBVH.Load(offsetToReadPrimitives);
    offsetToReadPrimitives += SizeOfUINT32;

    if (primitiveType == TRIANGLE_TYPE)
    {
        float3 v[NumberOfVerticesPerTriangle];
        [unroll]
        for (uint i = 0; i < NumberOfVerticesPerTriangle; i++)
        {
            v[i] = asfloat(outputBVH.Load3(offsetToReadPrimitives + i * SizeOfVertex));
        }

        return GetBoxDataFromTriangle(v[0], v[1], v[2], primitiveIndex, flags);
    }
    else // if(primitiveType == PROCEDURAL_PRIMITIVE_TYPE)
    {
        flags.x = primitiveIndex | IsLeafFlag | IsProceduralGeometryFlag;
        flags.y = 1;
    
        AABB aabb;
        aabb.min = asfloat(outputBVH.Load3(offsetToReadPrimitives));
        aabb.max = asfloat(outputBVH.Load3(offsetToReadPrimitives + 12));
        return AABBtoBoundingBox(aabb);
    }
}

#define BOTTOM_LEVEL 1

#include "ComputeAABBs.hlsli"
