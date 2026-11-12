package ${package}.mixin;

<#include "../mcitems.ftl">

import com.llamalad7.mixinextras.injector.ModifyReturnValue;
import com.llamalad7.mixinextras.sugar.Local;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.Unique;
import org.spongepowered.asm.mixin.injection.At;

/** Lets chorus plants survive on and connect down to this mod's end stone blocks. */
@Mixin(ChorusPlantBlock.class)
public abstract class ChorusPlantBlockMixin {

	@ModifyReturnValue(method = "canSurvive", at = @At("RETURN"))
	private boolean canSurviveOnEndstone(boolean canSurvive, @Local(argsOnly = true) LevelReader world, @Local(argsOnly = true) BlockPos pos) {
		return canSurvive || supportsChorus(world.getBlockState(pos.below()));
	}

	@ModifyReturnValue(method = "getStateForPlacement(Lnet/minecraft/world/item/context/BlockPlaceContext;)Lnet/minecraft/world/level/block/state/BlockState;", at = @At("RETURN"))
	private BlockState connectOnPlacement(BlockState plant, @Local(argsOnly = true) BlockPlaceContext ctx) {
		if (ctx.canPlace() && (plant.is(Blocks.CHORUS_PLANT) || plant.is(Blocks.CHORUS_FLOWER)) && supportsChorus(ctx.getLevel().getBlockState(ctx.getClickedPos().below())))
			return plant.trySetValue(BlockStateProperties.DOWN, true);
		return plant;
	}

	// The chorus plant, chorus flower and end stone cases already connect down in NeoForge, only the end stones are missing
	@ModifyReturnValue(method = "getStateWithConnections", at = @At("RETURN"))
	private static BlockState connectWithEndstone(BlockState state, @Local(argsOnly = true) BlockGetter blockGetter, @Local(argsOnly = true) BlockPos blockPos) {
		return isEndstone(blockGetter.getBlockState(blockPos.below())) ? state.trySetValue(BlockStateProperties.DOWN, true) : state;
	}

	@Unique
	private static boolean isEndstone(BlockState state) {
		return <#list endstones as endstone>state.is(${mappedBlockToBlock(endstone.block)})<#sep> || </#list>;
	}

	@Unique
	private static boolean supportsChorus(BlockState state) {
		return isEndstone(state) || state.is(Blocks.END_STONE);
	}

}
