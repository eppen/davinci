import path from 'path'
import resolve from '@rollup/plugin-node-resolve'
import commonjs from '@rollup/plugin-commonjs'
import esbuild from 'rollup-plugin-esbuild'

const chartCoreSrc = path.resolve(__dirname, '../chart-core/src')

export default {
  input: 'src/index.ts',
  output: {
    file: 'dist/mes-chart-runtime.js',
    format: 'umd',
    name: 'MesChartRuntime',
    sourcemap: true
  },
  plugins: [
    resolve({
      extensions: ['.ts', '.js'],
      alias: {
        '@mes/chart-core': chartCoreSrc
      }
    }),
    commonjs(),
    esbuild({
      include: /\.[jt]sx?$/,
      minify: false,
      target: 'es2017'
    })
  ]
}
