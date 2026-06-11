import React from 'react'
import { Modal, Button } from 'antd'
import { LAYOUT_PRESETS, ILayoutPreset } from '../constants/layoutPresets'
import styles from './LayoutSelector.less'

interface ILayoutSelectorProps {
  visible: boolean
  currentTemplate?: string
  widgetCount: number
  loading?: boolean
  onApply: (presetId: string) => void
  onCancel: () => void
}

interface ILayoutSelectorState {
  selectedId: string
}

function renderThumbBlocks(preset: ILayoutPreset) {
  return preset.slots.map((slot, index) => (
    <div
      key={index}
      className={styles.thumbBlock}
      style={{
        gridColumn: `${slot.x + 1} / span ${slot.width}`,
        gridRow: `${Math.floor(slot.y / 3) + 1} / span ${Math.max(1, Math.ceil(slot.height / 3))}`
      }}
    />
  ))
}

export class LayoutSelector extends React.PureComponent<ILayoutSelectorProps, ILayoutSelectorState> {
  constructor(props: ILayoutSelectorProps) {
    super(props)
    this.state = {
      selectedId: props.currentTemplate || LAYOUT_PRESETS[0].id
    }
  }

  public componentDidUpdate(prevProps: ILayoutSelectorProps) {
    if (this.props.visible && !prevProps.visible) {
      this.setState({
        selectedId: this.props.currentTemplate || LAYOUT_PRESETS[0].id
      })
    }
  }

  private selectPreset = (presetId: string) => () => {
    this.setState({ selectedId: presetId })
  }

  private handleApply = () => {
    this.props.onApply(this.state.selectedId)
  }

  public render() {
    const { visible, widgetCount, loading, onCancel } = this.props
    const { selectedId } = this.state
    const selectedPreset = LAYOUT_PRESETS.find((p) => p.id === selectedId)

    return (
      <Modal
        title="选择布局"
        visible={visible}
        onCancel={onCancel}
        footer={[
          <Button key="cancel" onClick={onCancel}>取消</Button>,
          <Button
            key="apply"
            type="primary"
            loading={loading}
            onClick={this.handleApply}
          >
            应用
          </Button>
        ]}
      >
        <p style={{ marginBottom: 16 }}>
          {widgetCount > 0
            ? `将按新布局重排 ${widgetCount} 个 Widget，是否继续？`
            : '选择布局模板，新增 Widget 时将自动按此模板占位。'}
        </p>
        <div className={styles.presetList}>
          {LAYOUT_PRESETS.map((preset) => (
            <div
              key={preset.id}
              className={`${styles.presetCard} ${selectedId === preset.id ? styles.selected : ''}`}
              onClick={this.selectPreset(preset.id)}
            >
              <div className={styles.presetName}>{preset.name}</div>
              <div className={styles.presetDesc}>{preset.description}</div>
              <div className={styles.presetThumb}>
                {renderThumbBlocks(preset)}
              </div>
            </div>
          ))}
        </div>
        {selectedPreset && (
          <p style={{ marginTop: 16, color: 'rgba(0,0,0,0.45)', fontSize: 12 }}>
            当前选中：{selectedPreset.name}
          </p>
        )}
      </Modal>
    )
  }
}

export default LayoutSelector
