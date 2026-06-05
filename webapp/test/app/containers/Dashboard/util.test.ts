import { combineFilters } from 'app/containers/Dashboard/util'

describe('combineFilters', () => {
  it('merges widget static, temp, linkage and global filters', () => {
    const result = combineFilters(
      ['{"name":"a"}'],
      ['{"name":"b"}'],
      ['{"name":"c"}'],
      ['{"name":"d"}']
    )
    expect(result).toEqual([
      '{"name":"a"}',
      '{"name":"b"}',
      '{"name":"c"}',
      '{"name":"d"}'
    ])
  })

  it('includes drill filters when provided', () => {
    const result = combineFilters(
      ['w'],
      ['t'],
      [],
      [],
      ['d']
    )
    expect(result).toEqual(['w', 't', 'd'])
  })

  it('handles empty arrays', () => {
    expect(combineFilters()).toEqual([])
  })
})
