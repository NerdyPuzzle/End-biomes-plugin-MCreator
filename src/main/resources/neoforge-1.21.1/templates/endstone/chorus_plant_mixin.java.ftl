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

	@ModifyReturnValue(method = "updateShape", at = @At("RETURN"))
	private BlockState connectOnShapeUpdate(BlockState plant, @Local(argsOnly = true) LevelAccessor world, @Local(argsOnly = true, ordinal = 0) BlockPos pos) {
		return connectDown(plant, world.getBlockState(pos.below()));
	}

	@ModifyReturnValue(method = "getStateForPlacement(Lnet/minecraft/world/item/context/BlockPlaceContext;)Lnet/minecraft/world/level/block/state/BlockState;", at = @At("RETURN"))
	private BlockState connectOnPlacement(BlockState plant, @Local(argsOnly = true) BlockPlaceContext ctx) {
		return ctx.canPlace() ? connectDown(plant, ctx.getLevel().getBlockState(ctx.getClickedPos().below())) : plant;
	}

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

	@Unique
	private static BlockState connectDown(BlockState plant, BlockState below) {
		return plant.is(Blocks.CHORUS_PLANT) && supportsChorus(below) ? plant.setValue(BlockStateProperties.DOWN, true) : plant;
	}

}
