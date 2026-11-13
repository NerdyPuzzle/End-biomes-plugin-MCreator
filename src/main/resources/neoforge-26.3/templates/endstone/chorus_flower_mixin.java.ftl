package ${package}.mixin;

<#include "../mcitems.ftl">

import net.minecraft.util.TriState;
import org.spongepowered.asm.mixin.Unique;

/** Lets chorus flowers survive on and grow from this mod's end stone blocks. */
@Mixin(ChorusFlowerBlock.class)
public abstract class ChorusFlowerBlockMixin {

	@ModifyReturnValue(method = "canSurvive", at = @At("RETURN"))
	private boolean canSurviveOnEndstone(boolean canSurvive, @Local(argsOnly = true) LevelReader world, @Local(argsOnly = true) BlockPos pos) {
		return canSurvive || isEndstone(world.getBlockState(pos.below()));
	}

	@WrapOperation(method = "randomTick", at = @At(value = "INVOKE", target = "Lnet/minecraft/world/level/block/state/BlockState;canSustainPlant(Lnet/minecraft/world/level/BlockGetter;Lnet/minecraft/core/BlockPos;Lnet/minecraft/core/Direction;Lnet/minecraft/world/level/block/state/BlockState;)Lnet/minecraft/util/TriState;"))
	private TriState canSustainChorus(BlockState soil, BlockGetter world, BlockPos soilPos, Direction facing, BlockState plant, Operation<TriState> original) {
		return isEndstone(soil) ? TriState.TRUE : original.call(soil, world, soilPos, facing, plant);
	}

	@Unique
	private static boolean isEndstone(BlockState state) {
		return <#list endstones as endstone>state.is(${mappedBlockToBlock(endstone.block)})<#sep> || </#list>;
	}

}