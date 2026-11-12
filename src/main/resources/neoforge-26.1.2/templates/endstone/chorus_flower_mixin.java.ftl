package ${package}.mixin;

<#include "../mcitems.ftl">

import net.minecraft.world.level.block.state.BlockBehaviour.Properties;

@Mixin(ChorusFlowerBlock.class)
public abstract class ChorusFlowerBlockMixin extends Block {
    public ChorusFlowerBlockMixin(Properties settings) {
        super(settings);
    }

	@Inject(method = "canSurvive", at = @At("HEAD"), cancellable = true)
	private void canSurvive(BlockState state, LevelReader world, BlockPos pos, CallbackInfoReturnable<Boolean> info) {
		BlockState blockstate = world.getBlockState(pos.below());
		if (<#list endstones as endstone>blockstate.is(${mappedBlockToBlock(endstone.block)}) <#sep>||</#list>) {
			info.setReturnValue(true);
		}
	}

	@WrapOperation(method = "randomTick", at = @At(value = "INVOKE", target = "Lnet/minecraft/world/level/block/state/BlockState;canSustainPlant(Lnet/minecraft/world/level/BlockGetter;Lnet/minecraft/core/BlockPos;Lnet/minecraft/core/Direction;Lnet/minecraft/world/level/block/state/BlockState;)Lnet/minecraft/util/TriState;"))
	private TriState canSustainChorus(BlockState soil, BlockGetter world, BlockPos soilPos, Direction facing, BlockState plant, Operation<TriState> original) {
		if (<#list endstones as endstone>soil.is(${mappedBlockToBlock(endstone.block)})<#sep> || </#list>) {
			return TriState.TRUE;
		}
		return original.call(soil, world, soilPos, facing, plant);
	}

}