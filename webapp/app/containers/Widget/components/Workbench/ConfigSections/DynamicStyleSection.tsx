import React from 'react'
import { Row, Col, Input, InputNumber, Select, Switch } from 'antd'
import { IChartStyleField } from '../../Widget'

const styles = require('../Workbench.less')

interface IDynamicStyleSectionProps {
  title?: string
  schema: IChartStyleField[]
  config: Record<string, string | number | boolean>
  onChange: (config: Record<string, string | number | boolean>) => void
}

const DynamicStyleSection: React.FC<IDynamicStyleSectionProps> = ({
  title = '样式',
  schema,
  config,
  onChange
}) => {
  const handleChange = (key: string, value: string | number | boolean) => {
    onChange({ ...config, [key]: value })
  }

  const renderField = (field: IChartStyleField) => {
    const value = config[field.key] !== undefined ? config[field.key] : field.default
    switch (field.component) {
      case 'number':
        return (
          <InputNumber
            value={value as number}
            onChange={(v) => handleChange(field.key, v)}
            style={{ width: '100%' }}
          />
        )
      case 'select':
        return (
          <Select
            value={value as string | number}
            onChange={(v) => handleChange(field.key, v)}
            style={{ width: '100%' }}
          >
            {(field.options || []).map((opt) => (
              <Select.Option key={String(opt.value)} value={opt.value}>
                {opt.label}
              </Select.Option>
            ))}
          </Select>
        )
      case 'switch':
        return (
          <Switch
            checked={!!value}
            onChange={(v) => handleChange(field.key, v)}
          />
        )
      case 'color':
        return (
          <Input
            type="color"
            value={String(value || '#1890ff')}
            onChange={(e) => handleChange(field.key, e.target.value)}
            style={{ width: '100%' }}
          />
        )
      case 'input':
      default:
        return (
          <Input
            value={String(value ?? '')}
            onChange={(e) => handleChange(field.key, e.target.value)}
          />
        )
    }
  }

  if (!schema || !schema.length) {
    return null
  }

  return (
    <div className={styles.paneBlock}>
      <h4>{title}</h4>
      {schema.map((field) => (
        <Row key={field.key} gutter={8} style={{ marginBottom: 8 }}>
          <Col span={8}>{field.title}</Col>
          <Col span={16}>{renderField(field)}</Col>
        </Row>
      ))}
    </div>
  )
}

export default DynamicStyleSection
